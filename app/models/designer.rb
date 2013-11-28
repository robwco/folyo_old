class Designer < User

  trackable :email, :full_name, :role, :created_at

  field :status,                  type: Symbol, default: :pending
  field :rejection_message
  field :profile_type,            type: Symbol, default: :public

  field :short_bio,               type: String
  field :long_bio,                type: String
  field :location,                type: String
  field :coordinates,             type: Array

  field :minimum_budget,          type: Integer
  field :rate,                    type: Integer

  field :portfolio_url,           type: String
  field :linkedin_url,            type: String

  field :twitter_username,        type: String
  field :behance_username,        type: String
  field :skype_username,          type: String
  field :dribbble_username,       type: String
  field :zerply_username,         type: String

  field :featured_shot_id,        type: String
  field :featured_shot_url,       type: String

  field :uploaded_photo

  field :skills,                  type: Array, default: []

  field :randomization_key,       type: Float # used to get a pseudo-random order of designers

  field :designer_pg_id # id of the designer in postgresql. Will be removed someday

  attr_accessor :skip_validation
  alias_method  :designer_projects, :projects

  with_options(unless: ->(d) { d.skip_validation }) do |d|
    d.validates_length_of :long_bio, maximum: 750, tokenizer: lambda { |str| str.scan(/./) }
  end

  ## relations ##
  has_many :posts,    class_name: 'DesignerPost', dependent: :destroy
  has_many :projects, class_name: 'DesignerProject', dependent: :destroy

  ## reference data ##

   def self.skills
    [:icon_design, :illustration, :logo_design, :mobile_design, :print_design, :UI_design, :UX_design, :web_design]
  end

  def self.statuses
    [:accepted, :pending, :rejected]
  end

  def self.profile_types
    [:public, :private, :hidden]
  end

  ## validations ##
  validates_presence_of     :portfolio_url
  validates_inclusion_of    :status,       in: Designer.statuses,      allow_blank: false
  validates_inclusion_of    :profile_type, in: Designer.profile_types, allow_blank: true

  ## scopes ##
  default_scope where(:_type.in => %w(Designer Html::Designer))

  scope :ordered_by_status, order_by(:status => :asc, :created_at => :desc)
  scope :random_order,      ->(order = :act){ order_by(:randomization_key => order) }

  scope :pending,           where(:status => :pending)
  scope :rejected,          where(:status => :rejected)
  scope :accepted,          where(:status => :accepted)
  scope :for_status,        ->(status) { where(status: status) }

  scope :public_only,       where(:profile_type => :public)
  scope :public_private,    where(:profile_type.in => [:public, :private])

  scope :san_francisco,     where(location: /San Francisco/i)
  scope :palo_alto,         where(location: /Palo Alto/i)


  ## callbacks ##
  before_validation  :process_skills, :fix_portfolio_url, :fix_dribbble_username
  before_save        :generate_mongoid_random_key
  after_save         :accept_reject_mailer, if: :status_changed?
  after_save         :tweet_out,            if: :status_changed?
  after_save         :geocode,              if: :location_changed?
  after_save         :update_dribbble_info, if: :dribbble_info_changed?
  before_destroy     :before_destroy

  ## indexes ##
  index coordinates: '2d'
  index pg_id: 1

  def role_name
    'designer'
  end

  def pending?
    self.status == :pending
  end

  def accepted?
    self.status == :accepted
  end

  def rejected?
    self.status == :rejected
  end

  def public?
    self.profile_type == :public
  end

  def profile_url
    "http://www.folyo.me/designers/#{self.to_param}"
  end

  def dribbble_url
    "http://dribbble.com/#{dribbble_username}" unless dribbble_username.blank?
  end

  def behance_url
    "http://www.behance.net/#{behance_username}" unless behance_username.blank?
  end

  def resources
    @resources ||= {}.tap do |resources|
      resources[:dribbble] = dribbble_url unless dribbble_username.blank?
      resources[:behance] = behance_url unless behance_username.blank?
      resources[:portfolio] = portfolio_url unless portfolio_url.blank?
    end
  end

  def track_signup_event
    track_user_event('Signup Designer')
  end

  protected

  def tweet_out
    if Rails.env.production? && self.public? && self.accepted? && !self.twitter_username.blank?
      Twitter.update("Welcome to @#{self.twitter_username}! Check out their profile here: #{profile_url}")
    end
  end
  handle_asynchronously :tweet_out

  def accept_reject_mailer
    if self.status_changed?
      if self.accepted?
        DesignerMailer.delay.accepted_mail(self)
        subscribe_to_newsletter
      elsif self.rejected?
        DesignerMailer.delay.rejected_mail(self)
      end
    end
  end

  def subscribe_to_newsletter
    if Rails.env.production?
      hominidapi = Hominid::API.new('1ba18f507cfd9c56d21743736aee9a40-us2')
      hominidapi.list_subscribe('d2a9f4aa7d', self.email, {}, 'html', false, true, true, false)
    end
  end
  handle_asynchronously :subscribe_to_newsletter

  def geocode
    unless Rails.env.test?
      self.coordinates = Geocoder.coordinates(self.location)
      save!
    end
  end
  handle_asynchronously :geocode

  def update_dribbble_info
    unless Rails.env.test?
      shot = featured_shot_id.blank? ? Dribbble::Player.find(dribbble_username).shots.first : Dribbble::Shot.find(featured_shot_id)
      if shot && !shot.respond_to?(:message) # to handle a #<Dribbble::Shot:0x007fee5f1bde10 @created_at=nil, @message="Not found">
        self.featured_shot_image_url = shot.image_url
        self.featured_shot_url = shot.url
        self.featured_shot_id = shot.id
        save!
      end
    end
  end
  handle_asynchronously :update_dribbble_info

  def process_skills
    self.skills.reject!(&:blank?) if self.skills_changed?
    self.skills.map!(&:to_sym)
  end

  def generate_mongoid_random_key
    self.randomization_key = rand
  end

  def dribbble_info_changed?
    self.dribbble_username_changed? || self.featured_shot_id_changed?
  end

  def fix_portfolio_url(force = false)
    if !self.portfolio_url.blank? && (self.portfolio_url_changed? || force)
      unless self.portfolio_url[/^http:\/\//] || self.portfolio_url[/^https:\/\//]
        self.portfolio_url = "http://#{self.portfolio_url}"
      end
    end
  end

  def fix_dribbble_username
    if self.dribbble_username =~ /http:\/\/dribbble.com\/(.*)/
      self.dribbble_username = $1
    end
  end

  def before_destroy
    JobOffer.elem_match(designer_replies: {designer_id: self.id}).each do |offer|
      offer.designer_replies.where(designer_id: self.id).destroy_all
    end
  end

end