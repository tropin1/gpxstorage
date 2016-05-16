class Layer < ApplicationRecord
  include LibSupport::BaseObject

  validates :name, :presence => true, :length => { :maximum => 50 }
  validates :url, :presence => true, :length => { :maximum => 512 }
  strip_attributes :only => [:name, :url]
  set_ref_columns  :name, :url
  has_many :tracks

  before_destroy do
    if predefined? || tracks.any?
      errors[:remove_list] << I18n.t('cannot_remove')
      raise ActiveRecord::Rollback
    end
  end

  def self.create_std_layers
    create [ { :name => I18n.t('layer.standard'), :url => 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', :predefined => true },
             { :name => I18n.t('layer.bike'), :url => 'https://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png', :predefined => true } ].select {|x|
        !where(:url => x[:url]).exists?
    }
  end

  def permit_modify?(*opts)
    Permissions.extract_user(*opts)&.admin?
  end
end