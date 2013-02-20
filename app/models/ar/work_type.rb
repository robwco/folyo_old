class AR::WorkType < ActiveRecord::Base

  self.table_name = 'work_types'

  has_many :job_offers

end
