class Track < ApplicationRecord
  include LibSupport::BaseObject
  belongs_to       :user
  has_many         :track_items
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

  def permit?(*opts)
    user = Permissions.extract_user(*opts)
    public? || permitted_for?(user)
  end

  def permit_modify?(*opts)
    permitted_for? Permissions.extract_user(*opts)
  end

  def self.permitted_for(*opts)
    user = Permissions.extract_user(*opts)
    return where(:public => true) unless user

    return all.with_users if user.admin?
    where(:public => true).with_users.or where(:user_id => user.get_id).with_users
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
end
