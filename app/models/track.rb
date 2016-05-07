class Track < ApplicationRecord
  include LibSupport::BaseObject
  belongs_to       :user
  strip_attributes :only => [:name, :descr]
  set_ref_columns  :name
  set_form_columns :name, :descr
  paginates_per 20

  validates   :name, :presence => true, :length => { :maximum => 255 }
  validates   :code, :presence => true, :uniqueness => true
  validates   :user, :presence => true
  validates   :public, :presence => true, :inclusion => { :in => [true, false] }

  after_initialize :created

  def permit?(*opts)
    user = Permissions.extract_user(opts)
    user && (public? || user.admin? || user_id == user.get_id)
  end

  def permit_modify?(*opts)
    user = Permissions.extract_user(opts)
    user && (user.admin? || user_id == user.get_id)
  end

  def self.permitted_for(*opts)
    super
  end

  private

  def created
    self.code = SecureRandom.hex(26)
  end
end
