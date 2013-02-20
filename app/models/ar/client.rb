class AR::Client < ActiveRecord::Base

  self.table_name = 'clients'

  belongs_to :user

  has_many :job_offers

  accepts_nested_attributes_for :job_offers, :limit => 1, :reject_if => :all_blank

  validates_presence_of :company_name, :company_description

  validates_associated :job_offers

  ## scopes ##
  scope :ordered, :order => 'created_at DESC'

  def role_name
    'client'
  end

  def email
    self.user.email
  end

  def full_name
    self.user.full_name
  end

  def class_name
    "Client"
  end

end
