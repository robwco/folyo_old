class AR::Role < ActiveRecord::Base

  self.table_name = 'roles'

  has_and_belongs_to_many :users
end