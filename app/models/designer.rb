class Designer < User

  field :status,                  type: Symbol, default: :pending
  field :rejection_message
  field :profile_type,            type: Symbol, default: :public
  field :profile_completeness,    type: Integer

  field :short_bio,               type: String
  field :long_bio,                type: String
  field :location,                type: String
  field :coordinates,             type: Array

  field :portfolio_url,           type: String

  field :twitter_username,        type: String
  field :behance_username,        type: String
  field :skype_username,          type: String
  field :dribbble_username,       type: String

  field :featured_shot_id,        type: String
  field :featured_shot_url,       type: String
  field :featured_shot_image_url, type: String

  field :skills,                  type: Array, default: []

  field :randomization_key,       type: Float # used to get a pseudo-random order of designers

  validates_length_of :long_bio, maximum: 750, tokenizer: lambda { |str| str.scan(/./) }

  embeds_many :projects, class_name: 'DesignerProject'
  embeds_one  :profile_picture,  as: 'profile'

  alias_method  :designer_projects, :projects

  def self.skills
    [:icon_design, :illustration, :logo_design, :mobile_design, :print_design, :UI_design, :UX_design, :web_design]
  end

  def self.statuses
    [:accepted, :pending, :rejected]
  end

  def self.profile_types
    [:public, :private, :hidden]
  end

  def self.completeness_fields
    [ :short_bio, :long_bio, :location, :portfolio_url, :twitter_username, :behance_username, :dribbble_username, :skype_username, :skills ]
  end

  validates_presence_of     :portfolio_url
  validates_inclusion_of    :status,       in: Designer.statuses,      allow_blank: false
  validates_inclusion_of    :profile_type, in: Designer.profile_types, allow_blank: true

  scope :ordered_by_status,     order_by(:status => :asc, :created_at => :desc)
  scope :random_order,          ->(order = :act){ order_by(:randomization_key => order) }
  scope :pending,               where(:status => :pending)
  scope :rejected,              where(:status => :rejected)
  scope :accepted,              where(:status => :accepted)
  scope :for_status,            ->(status) { where(status: status) }
  scope :public_only,           where(:profile_type => :public)
  scope :public_private,        where(:profile_type.in => [:public, :private])
  scope :san_francisco,         where(location: /San Francisco/i)
  scope :palo_alto,             where(location: /Palo Alto/i)
  scope :with_portfolio,        nor({:projects.exists => false}, {:projects.with_size => 0})
  scope :with_profile_picture,  where(:profile_picture.ne => nil)

  before_validation  :process_skills, :fix_portfolio_url, :fix_dribbble_username
  before_save        :generate_mongoid_random_key, :set_completeness
  after_save         :accept_reject_mailer, if: :status_changed?
  after_save         :tweet_out,            if: :status_changed?
  after_save         :geocode,              if: :location_changed?
  after_save         :update_vero_attributes
  before_destroy     :remove_replies, :unsubscribe_to_newsletter

  ## indexes ##
  index coordinates: '2d'

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

  def can_create_project?
    self.projects.count < 3
  end

  def set_completeness
    completeness = ::Designer.completeness_fields.sum { |f| self.send(f).blank? ? 0.0 : 1.0 } / ::Designer.completeness_fields.length * 65
    completeness += 5 if self.profile_picture
    completeness += projects.sum { |p| p.has_artworks? && !p.name.blank? && !p.description.blank? ? 10 : 0 }
    completeness = completeness.round(0)
    if self.profile_completeness != completeness
      self.update_attribute(:profile_completeness, completeness)
      track_user_event('Completed designer profile', completeness: completeness)
    end
  end

  def vero_attributes
    { email: self.email, status: self.status, full_name: self.full_name, role: self.role, slug: self.slug, created_at: self.created_at }
  end

  protected

  def tweet_out
    if Rails.env.production? && self.public? && self.accepted? && !self.twitter_username.blank?
      FolyoTwitter.new.update("Welcome to @#{self.twitter_username}! Check out their profile here: #{profile_url}")
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
      MailChimpHelper.new.list_subscribe(self.email)
    end
  end
  handle_asynchronously :subscribe_to_newsletter

  def unsubscribe_to_newsletter
    if Rails.env.production?
      MailChimpHelper.new.list_unsubscribe(self.email)
    end
  end
  handle_asynchronously :unsubscribe_to_newsletter

  def geocode
    unless Rails.env.test?
      self.coordinates = Geocoder.coordinates(self.location)
      save!
    end
  end
  handle_asynchronously :geocode

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

  def remove_replies
    JobOffer.elem_match(designer_replies: {designer_id: self.id}).each do |offer|
      offer.designer_replies.where(designer_id: self.id).destroy_all
    end
  end

  def update_vero_attributes
    if status_changed? || email_changed? || full_name_changed?
      vero.users.edit_user!(id: self.id.to_s, changes: {email: self.email, status: self.status, full_name: self.full_name, slug: self.slug})
    end
  end

end