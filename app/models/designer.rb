class Designer < User

  has_many :posts, class_name: 'DesignerPost', dependent: :destroy

  field :status,              type: Symbol
  field :profile_type,        type: Symbol

  field :short_bio,           type: String
  field :long_bio,            type: String
  field :location,            type: String
  field :coordinates,          type: Array

  field :minimum_budget,      type: Integer
  field :rate,                type: Integer

  field :portfolio_url,       type: String
  field :linkedin_url,        type: String

  field :twitter_username,    type: String
  field :behance_username,    type: String
  field :skype_username,      type: String
  field :dribbble_username,   type: String
  field :zerply_username,     type: String

  field :featured_shot,       type: String
  field :featured_shot_url,   type: String
  field :featured_shot_page,  type: String

  field :skills,              type: Array, default: []

  field :randomization_key,   type: Float # used to get a pseudo-random order of designers

  field :designer_pg_id # id of the designer in postgresql. Will be removed someday

  ## validations ##
  validates_presence_of :portfolio_url

  ## scopes ##
  scope :ordered_by_status, order_by(:status => :asc, :created_at => :desc)
  scope :random_order,      ->(order = :act){ order_by(:randomization_key => order) }

  scope :pending,           where(:status => :pending)
  scope :rejected,          where(:status => :rejected)
  scope :accepted,          where(:status => :accepted)
  scope :public_only,       where(:profile_type => :public)
  scope :public_private,    where(:profile_type.in => [:public, :private])

  ## callbacks ##
  before_save   :remove_empty_skills
  before_save   :generate_mongoid_random_key
  before_update :tweet_out, :accept_reject_mailer

  ## indexes ##
  index coordinates: '2d'

  def role_name
    'designer'
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
    "http://folyo.me/designers/#{self.id}"
  end

  def self.skills
    [:icon_design, :illustration, :logo_identity_design, :mobile_design, :print_design, :ui_design, :ux_interaction_design, :web_design]
  end

  def self.statuses
    [:accepted, :pending, :rejected]
  end

  def self.profile_types
    [:public, :private, :hidden]
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

  protected

  def tweet_out
    if Rails.env.production? && self.status_changed? && self.profile_type == :public && self.status == :accepted && !self.twitter_username.blank?
      Twitter.update("Welcome to @#{self.twitter_username}! Check out their profile here: http://folyo.me/designers/#{self.id}")
    end
  end

  def accept_reject_mailer
    if self.status_changed?
      if self.accepted?
        DesignerMailer.accepted_mail(self).deliver
      elsif self.rejected?
        DesignerMailer.rejected_mail(self).deliver
      end
    end
  end

  def remove_empty_skills
    self.skills.reject!(&:blank?) if self.skills_changed?
  end

  def generate_mongoid_random_key
    self.randomization_key = rand
  end

end