class Client < User

  trackable :email, :full_name, :role, :company_name, :created_at

  field :twitter_username,    type: String
  field :client_pg_id

  field :location,            type: String
  field :company_name,        type: String
  field :company_url,         type: String
  field :company_description, type: String

  field :next_offer_discount, type: Integer

  has_many :job_offers

  validates_inclusion_of :next_offer_discount, in: 1..100, allow_nil: true, message: 'must be between 1 and 100'

  def role_name
    'client'
  end

  def profile_url
    "http://www.folyo.me/clients/#{self.to_param}"
  end

  def track_signup_event
    track_user_event('Signup Client')
  end

end