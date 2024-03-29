require 'mailchimp_helper'

class Designer < User

  include Sidekiq::Delay

  def self.skills
    %i(logo_and_identity_design illustration motion_design web_design UI_design UX_design print_design type_lettering)
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

  def self.subscription_modes
    [ :all_offers, :none ] # :offers_matching_your_skills
  end

  field :status,                  type: Symbol, default: :pending
  field :rejection_message
  field :profile_type,            type: Symbol, default: :public
  field :profile_completeness,    type: Integer
  field :subscription_mode,       type: Symbol, default: :all_offers

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
  field :skills_budgets,          type: Hash,  default: {}
  field :randomization_key,       type: Float # used to get a pseudo-random order of designers
  field :referral_token,          type: String

  field :paypal_email,            type: String

  field :applied_at,              type: DateTime
  field :accepted_at,             type: DateTime
  field :rejected_at,             type: DateTime

  validates_length_of :long_bio, maximum: 750, tokenizer: lambda { |str| str.scan(/./) }

  embeds_many :projects, class_name: 'DesignerProject', validate: false
  embeds_one  :profile_picture,  as: 'profile'

  alias_method  :designer_projects, :projects

  validates_presence_of     :portfolio_url
  validates_inclusion_of    :status,            in: Designer.statuses,           allow_blank: false
  validates_inclusion_of    :profile_type,      in: Designer.profile_types,      allow_blank: true
  validates_inclusion_of    :subscription_mode, in: Designer.subscription_modes, allow_blank: true
  validates                 :paypal_email, presence: true, format: { with: /\A[^@]+@[^@]+\z/, message: 'is not a valid email adress' }

  scope :ordered_by_status,     -> { order_by(:status => :asc, :created_at => :desc) }
  scope :ordered_by_name,       -> { order_by(full_name: :asc) }
  scope :random_order,          ->(order = :act){ order_by(:randomization_key => order) }
  scope :pending,               -> { where(:status => :pending) }
  scope :rejected,              -> { where(:status => :rejected) }
  scope :accepted,              -> { where(:status => :accepted) }
  scope :for_status,            ->(status) { where(status: status) }
  scope :for_skill,             ->(skill) { where('$or' => [{:"skills_budgets.#{skill}".ne => nil}, {skills: skill}]) }
  scope :public_only,           -> { where(:profile_type => :public) }
  scope :public_private,        -> { where(:profile_type.in => [:public, :private]) }
  scope :san_francisco,         -> { where(location: /San Francisco/i) }
  scope :palo_alto,             -> { where(location: /Palo Alto/i) }
  scope :with_portfolio,        -> { where('projects.artworks.status' => :processed) }
  scope :with_profile_picture,  -> { where(:profile_picture.ne => nil) }
  scope :subscribed_for,        ->(topics) { where('$or' => [ { subscription_mode: :all_offers }, { subscription_mode: :offers_matching_your_skills, :skills.in => topics }]) }

  before_create      :set_referral_token
  before_create      :set_applied_at
  before_validation  :fix_portfolio_url, :fix_twitter_username, :fix_behance_username, :fix_dribbble_username, :set_paypal_email
  before_save        :generate_mongoid_random_key, :set_completeness
  before_save        :set_moderation_dates, if: :status_changed?
  after_save         :accept_reject_mailer, if: :status_changed?
  after_save         :tweet_out,      if: :status_changed?
  after_save         :geocode,        if: :location_changed?
  after_save         :update_vero_attributes
  before_destroy     :remove_replies, :unsubscribe_to_newsletter

  ## indexes ##
  index coordinates: '2d'
  index referral_token: 1

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

  def twitter_url
    "https://twitter.com/#{twitter_username}" unless twitter_username.blank?
  end

  def social_urls
    { portfolio: portfolio_url, dribbble: dribbble_url, behance: behance_url, twitter: twitter_url }.delete_if { |k, v| v.nil? }
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

  def showable_projects
    self.projects.where('artworks.status' => :processed)
  end

  def has_showable_projects?
    self.showable_projects.count > 0
  end

  def set_completeness
    completeness = ::Designer.completeness_fields.sum { |f| self.send(f).blank? ? 0.0 : 1.0 } / ::Designer.completeness_fields.length * 65
    completeness += 5 if self.profile_picture
    completeness += projects.sum { |p| p.has_artworks? && !p.name.blank? && !p.description.blank? ? 10 : 0 }
    completeness = completeness.round(0)
    if self.profile_completeness != completeness
      track_user_event('Completed designer profile', completeness: completeness)
    end
  end

  def vero_attributes
    { email: self.email, status: self.status, full_name: self.full_name, role: self.role, slug: self.slug, created_at: self.created_at }
  end

  def referrals
    JobOffer.where(referring_designer: self).order_by(created_at: :desc).map do |offer|
      referral = if offer.rejected? || offer.refunded?
        { status: :ko, label: 'Offer has been canceled.' }
      elsif offer.live?
        if offer.order.referral_bonus_available?
          if offer.order.referral_bonus_transfered_at
            { status: :transfered, label: "Your $#{offer.order.referral_bonus.round(2)} bonus has been transfered on #{offer.order.referral_bonus_transfered_at.strftime("%m/%d/%Y")}." }
          else
            { status: :available, label: "Your $#{offer.order.referral_bonus.round(2)} bonus is available." }
          end
        else
          { status: :pending, label: "Your $#{offer.order.referral_bonus} bonus will be available on #{offer.order.referral_bonus_available_at.strftime("%m/%d/%Y")}." }
        end
      end
      { offer: offer, status: referral[:status], label: referral[:label] }
    end
  end

  def transfer_referral_bonus
    response = EXPRESS_GATEWAY.transfer(self.referral_balance * 100, self.paypal_email, subject:  'Folyo Referral bonus', note: 'Thanks for sharing Folyo around!')
    if response.success?
      JobOffer.with_available_bonus_for_designer(self).each do |offer|
        offer.order.mark_bonus_as_transfered!
      end
      true
    else
      false
    end
  end

  def referral_balance
    JobOffer.with_available_bonus_for_designer(self).sum { |offer| offer.order.referral_bonus }
  end

  def update_intercom_attributes
    user = Intercom::User.find(user_id: self.id) rescue Intercom::User.new
    user.user_id = self.id.to_s
    user.email = self.email
    user.name = self.full_name
    user.created_at = self.created_at
    user.custom_data = {
      role: 'designer',
      status: self.status,
      slug: self.slug,
      profile: "http://www.folyo.me/designers/#{self.slug}",
      profile_completeness: self.profile_completeness
    }
    user.save
  end

  def self.featured_designers(count)
    designers = Designer.public_only.accepted.with_portfolio.with_profile_picture # we pick only designers with profile picture & portfolio
    designers = designers.order_by(randomization_key: :asc)           # sort them in pseudo-random order
    designers = designers.offset(rand(designers.count - count + 1))   # start from a random position (with enough designers ahead)
    designers = designers.limit(3 * count)                            # get more designers than needed
    designers.to_a.sample(count)                                      # pick an exact size sample of designers
  end

  def pending_rank
    Designer.pending.where(:applied_at.lte => self.applied_at).count
  end

  def skills
    self.skills_budgets.keys.map(&:to_sym)
  end

  def tweet_out
    self.delay.async_tweet_out if Rails.env.production? && self.public? && self.accepted? && !self.twitter_username.blank?
  end

  def async_tweet_out
    FolyoTwitter.new.update("Welcome to @#{self.twitter_username}! Check out their profile here: #{profile_url}") if Rails.env.production?
  end

  def subscribe_to_newsletter
    self.delay.async_subscribe_to_newsletter if Rails.env.production?
  end

  def async_subscribe_to_newsletter
    MailChimpHelper.new.list_subscribe(self.email) if Rails.env.production?
  end

  def unsubscribe_to_newsletter
    self.delay.async_unsubscribe_to_newsletter if Rails.env.production?
  end

  def async_unsubscribe_to_newsletter
    MailChimpHelper.new.list_unsubscribe(self.email) if Rails.env.production?
  end

  def geocode
    self.delay.async_geocode unless Rails.env.test?
  end

  def async_geocode
    self.coordinates = Geocoder.coordinates(self.location)
    save!
  end

  protected

  def set_moderation_dates
    if self.status_changed?
      if self.accepted?
        self.accepted_at = DateTime.now
      elsif self.rejected?
        self.rejected_at = DateTime.now
      end
    end
  end

  def accept_reject_mailer
    if self.status_changed?
      if self.accepted?
        track_user_event('accepted')
        DesignerMailer.sidekiq_delay.accepted_mail(self.id)
        subscribe_to_newsletter
      elsif self.rejected?
        track_user_event('rejected')
        DesignerMailer.sidekiq_delay.rejected_mail(self.id)
      end
    end
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
    if self.dribbble_username =~ /http(s)?:\/\/(www\.)?dribbble\.com\/(.*)/
      self.dribbble_username = $3
    end
  end

  def fix_behance_username
    if self.behance_username =~ /http(s)?:\/\/(www\.)?behance\.net\/(.*)/
      self.behance_username = $3
    end
  end

  def fix_twitter_username
    if self.twitter_username =~ /http(s)?:\/\/(www\.)?twitter\.com\/(.*)/
      self.twitter_username = $3
    elsif self.twitter_username =~ /@(.*)/
      self.twitter_username = $1
    end
  end

  def remove_replies
    JobOffer.elem_match(designer_replies: {designer_id: self.id}).each do |offer|
      offer.designer_replies.where(designer_id: self.id).destroy_all
    end
  end

  def update_vero_attributes
    if status_changed? || email_changed? || full_name_changed?
      vero.users.edit_user!(id: self.id.to_s, changes: {email: self.email, status: self.status, full_name: self.full_name, slug: self.slug}) unless Rails.env.test?
    end
  end

  def set_referral_token
    self.referral_token ||= Mongoid::UidGenerator.get_uid_for(Designer, 8, 'referral_token')
  end

  def set_applied_at
    self.applied_at ||= DateTime.now
  end

  def set_paypal_email
    self.paypal_email ||= self.email
  end

end
