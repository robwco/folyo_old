class AR::Skill < ActiveRecord::Base

  self.table_name = 'skills'

  has_and_belongs_to_many :designers
  has_and_belongs_to_many :job_offers
end
