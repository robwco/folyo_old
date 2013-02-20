class AR::LocationType < ActiveRecord::Base

  self.table_name = 'location_types'

  has_many :job_offers
end
