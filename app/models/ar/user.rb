class AR::User < ActiveRecord::Base

  self.table_name = 'users'

  # Vero trackable
  # include Vero::Trackable
  # trackable :email, :full_name, :created_at, :role

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :full_name, :referrer, :referrer_designer
  attr_accessible :client_attributes, :designer_attributes

  validates_presence_of :full_name

  has_and_belongs_to_many :roles

  has_one :client
  has_one :designer

  has_many :messages

  accepts_nested_attributes_for :client, :reject_if => :all_blank
  accepts_nested_attributes_for :designer, :reject_if => :all_blank

  validates :email, :email => true

  after_create :new_user_created

  #should validate but only after create… disabled for now
  #validate :designer_or_client

  attr_accessible :initial_role

  def initial_role=(role_name)
    @initial_role = role_name
    role = Role.find_by_role_name(role_name)
    self.roles << role
  end

  def initial_role
    @initial_role
  end

  def role_by_name(role_name)
    self.roles.find_by_role_name(role_name.to_s)
  end

  def role?(role_name)
    !!self.roles.find_by_role_name(role_name.to_s)
  end

  def role
    # get the first role, since users only have one role for now
    self.roles.first.role_name rescue nil
  end

  def profile_url
    if self.role? :client
      "http://folyo.me/clients/#{self.client.id}"
    elsif self.role? :designer
      "http://folyo.me/designers/#{self.designer.id}"
    else
      "n/a"
    end
  end

  def profile
   if self.role? :client
      self.client
    elsif self.role? :designer
      self.designer
    end
  end

  def profile_path
   if self.role? :client
      self.client
    elsif self.role? :designer
      self.designer
    else
      logger.error("no profile path")
    end
  end

  def track_user_action(event, properties={})
    # Vero
    self.track(event, properties)
    # @klaviyo=Klaviyo::Client.new("7UwzvN", request.env)
    # @klaviyo.track(event, self.email, properties)
  end

  def new_user_created
    self.track("Signed Up")
  end
  # https://github.com/ryanb/cancan/wiki/Separate-Role-Model
  # if previous method doesn't work, try this one
  # def role?(role_sym)
  #   puts "roles, checking for #{role_sym}: #{roles}"
  #   roles.any? { |r| r.role_name.underscore.to_sym == role_sym }
  # end

  #https://github.com/justinfrench/formtastic/issues/232
  #seems easier to build client/designer in their respective views, so commented-out for now
  # def initialize(*args)
  #    super
  #    build_client unless client
  #    build_designer unless designer
  #  end

  private

     # def designer_or_client
     #   if (designer.blank? && client.blank?)
     #     errors.add_to_base("User should be associated to either a client or a designer profile")
     #   end
     # end
end
