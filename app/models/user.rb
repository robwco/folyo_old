class User

  include Mongoid::Document
  include Mongoid::Timestamps

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  field :full_name, type: String
  field :role,      type: Symbol
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

end