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

  #validates_presence_of :company_name, :company_description
  validates_inclusion_of :next_offer_discount, in: 1..100, allow_nil: true

  ## scopes ##
  default_scope where(:_type.in => %w(Client Html::Client))

  def role_name
    'client'
  end

  def profile_url
    "http://www.folyo.me/clients/#{self.to_param}"
  end

  def text_format
    :markdown
  end

  def track_signup_event
    track_user_event('Signup Client')
  end

end