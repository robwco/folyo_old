class AR::ProfileType < ActiveRecord::Base

  self.table_name = 'profile_types'

  has_many :designers
end
