class User

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Vero::Trackable

  slug      :full_name, history: true
  devise    :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  field :full_name, type: String
  field :referrer,  type: String

  ## Database authenticatable
  field :email,              :type => String, :default => ''
  field :encrypted_password, :type => String, :default => ''

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_at,    :type => Time
  field :last_sign_in_ip,    :type => String

  field :pg_id

  ## Relations ##
  has_many    :messages, inverse_of: :from_user
  belongs_to  :referrer_designer, class_name: 'Designer'

  ## Scopes ##
  scope :ordered, order_by(:created_at => :desc)

  after_create :track_signup_event

  ## Validation ##
  validates_presence_of :full_name

  def role
    _type.downcase
  end

  def track_user_event(event, properties = {})
    Rails.logger.debug "tracking event #{event} with properties #{properties.inspect}"
    EventTracker.track_user_action(self, event, properties)
  end

  def track_signup_event
    track_user_event('Signup')
  end

end