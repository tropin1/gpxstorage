class BaseObject < ActiveRecord::Base
  include LibSupport::BaseObject
  self.table_name = 'objects'
  self.inheritance_column = nil
end