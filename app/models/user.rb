class User

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Vero::DSL

  slug      :full_name, history: true
  devise    :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  field :full_name, type: String
  field :referrer,  type: String
  field :intercom_enabled, type: Boolean, default: false

  ## Database authenticatable
  field :email,              :type => String
  field :encrypted_password, :type => String

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

  ## Relations ##
  has_many    :messages, inverse_of: :from_user
  belongs_to  :referrer_designer, class_name: 'Designer'

  ## Scopes ##
  scope :ordered,   -> { order_by(created_at: :desc) }
  scope :for_email, ->(email){ where(email: email) }

  after_create :create_vero_user

  validates_presence_of :full_name

  before_destroy do
    Intercom::User.delete(user_id: self.id.to_s)
  end

  alias :name :full_name

  def role
    _type.downcase
  end

  def track_user_event(event, properties = {})
    self.delay.async_track_user_event(event, properties) unless Rails.env.test?
  end

  def async_track_user_event(event, properties = {})
    vero.events.track!(identity: {id: self.id.to_s}, event_name: event, data: properties) unless Rails.env.test?
    if Rails.env.production?
      Intercom::Event.create(event_name: event, email: self.email, created_at: DateTime.now, metadata: properties )
    end
  end

  protected

  def create_vero_user
    vero.users.track!(id: self.id.to_s, data: vero_attributes) unless Rails.env.test?
  end

end
