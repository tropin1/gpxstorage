class User < ApplicationRecord
  include LibSupport::BaseObject

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :recoverable, :validatable, :registerable

  devise      :database_authenticatable, :rememberable, :trackable,
              :omniauthable, :omniauth_providers => [ :google_oauth2 ]

  validates   :name, :presence => true, :length => { :maximum => 255 }
  validates   :email, :presence => true, :uniqueness => true

  strip_attributes :only => [ :name, :email ]
  set_ref_columns  :name, :email
  set_form_columns :name, :admin
  paginates_per 10

  has_many :tracks

  def self.find_for_google_oauth2(access_token, signed_in_resource = nil)
    data = access_token.info
    user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first || \
           User.where(:email => access_token.info.email).first || \
           User.new(:password => Devise.friendly_token[0, 20])

    user.update :name => data['name'], :provider => access_token.provider, :email => data['email'], :uid => access_token.uid
    user
  end

  # can change only yourself unless you're admin
  def permit_modify?(*opts)
    user = opts.extract_options!.dup[:user]
    user && ( user.admin? || user.get_id == get_id)
  end

end
