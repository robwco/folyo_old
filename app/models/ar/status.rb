class AR::Status < ActiveRecord::Base

  self.table_name = 'statuses'

  has_many :job_offers
  has_many :designers
end
