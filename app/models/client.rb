class Client < User

  CURRENT_MODEL_VERSION = 2

  trackable :email, :full_name, :role, :company_name, :created_at

  field :model_version,       type: Integer,  default: CURRENT_MODEL_VERSION
  field :twitter_username,    type: String
  field :client_pg_id

  field :location,            type: String
  field :company_name,        type: String
  field :company_url,         type: String
  field :company_description, type: String

  has_many :job_offers

  #validates_presence_of :company_name, :company_description

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