class Track < ActiveRecord::Base
  DEFAULT_COLOR = 'dodgerblue'

  include LibSupport::BaseObject
  include TrackLen

  belongs_to       :user
  belongs_to       :layer
  has_many         :track_items, -> { order(:name) }, foreign_key: :track_code, dependent: :destroy
  strip_attributes :only => [:name, :descr]
  set_ref_columns  :user_name, :name, :len, :created_at
  set_form_columns :name, :descr, :public
  set_id_column    :code
  paginates_per    10

  validates   :name, :presence => true, :length => { :maximum => 255 }
  validates   :code, :presence => true, :uniqueness => true
  validates   :user, :layer, :presence => true
  validates   :public, :inclusion => { :in => [true, false] }

  set_default_value(:layer) { Layer.first }
  set_default_value(:code) { TmpFiles::gen_hex }

  after_save       :pin_items
  after_commit     { user.refresh_cache }
  after_commit(on: [:create, :update]) { TrackWorker.perform_async(code) unless @lock }  # to calc all distances

  def calc_distances!
    ar = []

    track_items.map do |item|
      file = GPX::GPXFile.new(:gpx_data => item.data)

      item.update :len => file.distance
      ar << item.len
    end

    @lock = true
    update :len => ar.sum
  ensure
    @lock = nil
  end

  def get_data
    TmpFiles.pack name, track_items
  end

  def permit?(*opts)
    user = Permissions.extract_user(*opts)
    public? || permitted_for?(user)
  end

  def permit_modify?(*opts)
    permitted_for? Permissions.extract_user(*opts)
  end

  def self.permitted_for(*opts)
    user = Permissions.extract_user(*opts)
    res = case when user.nil? then where(:public => true)
               when user.admin? then all
            else where(:public => true).or where(:user_id => user.get_id)
          end

    res.with_users
  end

  def track_items
    @items_cache || super
  end

  def track_items=(value)
    @items_cache = (value || {}).map do |_, val|
      {:color => DEFAULT_COLOR}.merge(val.symbolize_keys.delete_if{|__, v| v.nil? || v.to_s.empty? }).methods_for_keys
    end
  end

  def user_name
    user.name
  end

  def self.with_users
    joins(:user).includes(:user)
  end

  private

  def permitted_for?(user)
    user && (user.admin? || user_id.nil? || user_id == user.get_id)
  end

  def pin_items
    return unless @items_cache

    values = @items_cache
    @items_cache = nil

    for_update = values.map{|x| x[:update_id] }.compact
    for_update.each do |id|
      value = values.select{|x| x[:update_id] == id }.first
      item = track_items.where(:id => id).first

      item.update :name => value[:name], :color => value[:color] if item && value
    end

    track_items.where.not(:id => for_update ).destroy_all
    values.select {|x| x[:update_id].nil? }.each { |item|
      TrackItem.create :name => item[:name], :color => item[:color], :track => self,
                       :data => TmpFiles.read(item[:code])
    }
  end
end
