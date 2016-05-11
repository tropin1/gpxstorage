class Track < ApplicationRecord
  DEFAULT_COLOR = 'dodgerblue'

  include LibSupport::BaseObject
  belongs_to       :user
  has_many         :track_items, -> { order(:created_at) }, foreign_key: :track_code
  strip_attributes :only => [:name, :descr]
  set_ref_columns  :name, :user_name, :public, :created_at
  set_form_columns :name, :descr, :public
  set_id_column    :code
  paginates_per 20

  validates   :name, :presence => true, :length => { :maximum => 255 }
  validates   :code, :presence => true, :uniqueness => true
  validates   :user, :presence => true
  validates   :public, :inclusion => { :in => [true, false] }

  after_initialize { self.code ||= SecureRandom.hex(26) }
  after_save  :pin_items

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
