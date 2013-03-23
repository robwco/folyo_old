class Client < User

  trackable :email, :full_name, :role, :created_at

  field :location,            type: String
  field :company_name,        type: String
  field :company_url,         type: String
  field :company_description, type: String
  field :twitter_username,    type: String

  field :client_pg_id

  validates_presence_of :company_name, :company_description

  has_many :job_offers

  def role_name
    'client'
  end

  def profile_url
    "http://www.folyo.me/clients/#{self.id}"
  end

end