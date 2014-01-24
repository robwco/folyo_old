# encoding: UTF-8

class JobOffer

  PRICE = 99
  DEFAULT_DISCOUNT = 20
  REFERAL_FEE = 20

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include ActionView::Helpers::NumberHelper

  # using routes for Event tracking
  include Rails.application.routes.url_helpers
  default_url_options[:host] = HOST

  field :title,               type: String
  field :project_summary,     type: String
  field :project_details,     type: String
  field :inspiration,         type: String
  field :timeframe,           type: String
  field :compensation,        type: Integer
  field :work_type,           type: Symbol
  field :location_type,       type: Symbol
  field :comp_high,           type: Integer
  field :coding,              type: Symbol,   default: :optional
  field :budget_range,        type: String
  field :budget_type,         type: Symbol,   default: :senior
  field :skills,              type: Array,    default: []

  field :location,            type: String
  field :company_name,        type: String
  field :company_url,         type: String
  field :company_description, type: String

  field :discount,            type: Integer

  field :is_open,             type: Boolean,  default: true
  field :status,              type: Symbol
  field :review_comment,      type: String
  field :refund_origin,       type: Symbol
  field :dead,                type: Boolean,  default: false

  field :published_at,        type: DateTime
  field :submited_at,         type: DateTime
  field :paid_at,             type: DateTime
  field :approved_at,         type: DateTime
  field :rejected_at,         type: DateTime
  field :sent_at,             type: DateTime
  field :archived_at,         type: DateTime
  field :rated_at,            type: DateTime
  field :refunded_at,         type: DateTime
  field :dead_at,             type: DateTime

  slug :title, history: true

  belongs_to  :client
  belongs_to  :referring_designer, class_name: 'Designer'
  embeds_many :designer_replies
  embeds_one  :order

  def self.coding_options
    [:not_needed, :optional, :mandatory]
  end

  def self.budget_ranges
    ['No precise idea yet' ,'Under $1000', '$1000-$1500', '$1500-$2000', '$2000-$3000', '$3000-$4000', '$4000-$5000', '$5000-$6000', '$6000-$7500', '$7500-$10000', '$10000-$15000', '$15000-$20000', '$20000+']
  end

  def self.work_types
    [:freelance, :full_time]
  end

  def self.location_types
    [:local, :remote]
  end

  def self.budget_types
    [:junior, :senior, :superstar]
  end

  def discounted_price
    if discount.nil?
      PRICE
    else
      PRICE * (1 - discount.to_f/100)
    end
  end

  def paypal_price
    discounted_price * 100
  end

  def display_price
    number_to_currency(discounted_price)
  end

  ## validations ##
  with_options(unless: ->(o) { o.skip_validation }) do |o|
    o.validates_presence_of     :title
    o.validates_presence_of     :company_name, :company_description, :project_summary, :project_details, :coding
    o.validates_length_of       :project_summary, maximum: 200, tokenizer: lambda { |str| str.scan(/./) }
    o.validates_length_of       :project_details, maximum: 800, tokenizer: lambda { |str| str.scan(/./) }
    o.validates_presence_of     :review_comment,  if: 'self.status == :rejected'
    o.validates_numericality_of :compensation,  allow_nil: true
    o.validates_inclusion_of    :coding,        in: JobOffer.coding_options, allow_blank: true
    o.validates_inclusion_of    :work_type,     in: JobOffer.work_types,     allow_blank: true
    o.validates_inclusion_of    :location_type, in: JobOffer.location_types, allow_blank: true
    o.validates_presence_of     :skills, message: 'Select at least one skill'
    o.validates_inclusion_of    :budget_range,  in: JobOffer.budget_ranges,  allow_blank: true
    o.validates_inclusion_of    :budget_type,   in: JobOffer.budget_types,   allow_blank: true
    o.validates_presence_of     :budget_range, :budget_type
  end

  ## callbacks ##
  before_validation :process_skills
  after_save        :set_client_attributes

  ## scopes ##
  # TODO: still need to put null values at the end
  scope :ordered, order_by(refunded_at: :desc, archived_at: :desc, approved_at: :desc, paid_at: :desc, created_at: :desc)
  scope :ordered_by_creation, order_by(created_at: :desc)
  scope :ordered_by_status, order_by(status: :asc)

  scope :initialized,            where(status: :initialized)
  scope :waiting_for_submission, where(status: :waiting_for_submission)
  scope :waiting_for_payment,    where(status: :waiting_for_payment)
  scope :waiting_for_review,     where(status: :waiting_for_review)
  scope :accepted,               where(status: :accepted)
  scope :rejected,               where(status: :rejected)
  scope :sent,                   where(status: :sent)
  scope :archived,               where(status: :archived)
  scope :rated,                  where(status: :rated)
  scope :pending,                where(:status.in => [:waiting_for_submission, :waiting_for_payment, :waiting_for_review, :rejected])
  scope :archived_or_rated,      where(:status.in => [:archived, :rated])
  scope :accepted_or_sent,       where(:status.in => [:accepted, :sending, :sent])
  scope :refunded,               where(status: :refunded)
  scope :for_designer, ->(designer) { elem_match(designer_replies: {designer_id: designer.id}) }
  scope :not_dead,               where(:dead.ne => true)

  attr_accessor :skip_validation

  def self.new_for_client(client)
    JobOffer.new.tap do |o|
      o.client = client
      o.location = client.location
      o.company_name = client.company_name
      o.company_description = client.company_description
      o.company_url = client.company_url
    end
  end

  state_machine :status, initial: :initialized do

    event :publish do
      transition :initialized => :waiting_for_submission
      transition any          => same
    end

    event :submit do
      transition :initialized            => :waiting_for_payment
      transition :waiting_for_submission => :waiting_for_payment
      transition :rejected               => :waiting_for_review
    end

    event :pay do
      transition :waiting_for_payment => :waiting_for_review
    end

    event :accept do
      transition :waiting_for_review => :accepted
      transition :rejected => :accepted
    end

    event :reject do
      transition :waiting_for_review => :rejected
    end

    event :prepare_for_sending do
      transition :accepted => :sending
      transition :sending  => same
    end

    event :cancel_sending do
      transition :sending  => :accepted
      transition :accepted => same
    end

    event :mark_as_sent do
      transition :sending =>  :sent
      transition :accepted => :sent
    end

    event :archive do
      transition :accepted => :archived
      transition :sent     => :archived
      transition :archived => same
      transition :rated    => same
    end

    event :rate do
      transition :archived => :rated
      transition :rated    => same
    end

    event :refund do
      transition :sent     => :refunded
      transition :accepted => :refunded
      transition :rejected => :refunded
      transition :archived => :refunded
      transition :rated    => :refunded
    end

    after_transition :status_changed

    states.each do |state|
      self.state(state.name, :value => state.name.to_sym)
    end

  end

  def client_email
    self.client.email
  end

  def live?
    [:accepted, :archived, :sending, :sent, :rated, :refunded].include? self.status
  end

  def published?
    [:accepted, :archived, :sending, :sent, :rated].include? self.status
  end

  def reply_by(designer)
    designer_replies.select{|r| r.designer_id == designer.id}.first
  end

  # archive the offer and mark some designer replies as picked
  def archive(picked_designer_id = nil, send_email = true)
    self.designer_replies.each do |reply|
      if reply.designer_id.to_s == picked_designer_id.to_s
        reply.picked = true
      else
        reply.picked = false
        if send_email
          DesignerMailer.delay.rejected_reply(reply.designer, self)
        end
      end
    end
    fire_events(:archive)
  end

  def kill
    unless self.dead
      Rails.logger.debug("Setting offer #{self.slug || self.id} as dead")
      JobOffer.where(id: self.id).update_all(dead: true, dead_at: DateTime.now) # will skip validation !
    end
  end

  def reject(review_comment)
    self.review_comment = review_comment
    fire_events(:reject)
  end

  def refund(discount = false)
    if order.refund
      fire_events(:refund)
      if discount
        client.update_attribute(:next_offer_discount, DEFAULT_DISCOUNT)
      end
    else
      Rails.logger.warn("Could not refund offer #{self.slug || self.id}")
    end
  end

  def location
    self[:location] || self.client.try(:location)
  end

  def company_name
    self[:company_name] || self.client.try(:company_name)
  end

  def company_url
    self[:company_url] || self.client.try(:company_url)
  end

  def refund_if_needed!(delay)
    if self.rejected? && self.rejected_at && self.rejected_at <= delay.ago
      Rails.logger.debug("Refunding offer #{self.slug || self.id}")
      self.skip_validation = true
      self.refund
    end
  end

  def kill_if_needed!(delay)
    if (self.waiting_for_submission? && (self.created_at.nil? || self.created_at <= delay.ago)) || (self.waiting_for_payment? && (self.submited_at.nil? || self.submited_at <= delay.ago))
      self.skip_validation = true
      self.kill
    end
  end

  def archive_if_needed!(delay)
    if (self.sent? && (self.sent_at.nil? || self.sent_at <= delay.ago)) || (self.accepted? && (self.approved_at.nil? || self.approved_at <= delay.ago))
      Rails.logger.debug("Archiving offer #{self.slug || self.id}")
      self.skip_validation = true
      self.fire_events(:archive)
    end
  end

  def set_client_discount!
    if client.next_offer_discount
      self.discount = client.next_offer_discount
      client.next_offer_discount = nil
      save!
      client.save!
    end
  end

  protected

  def track_event(event_name, optional_data = {})
    self.client.track_user_event(event_name, optional_data.merge(job_offer_title: self.title, job_offer_id: self.id.to_s, job_offer_slug: self.slug || self.id.to_s, company_name: self.client.company_name))
  end

  def status_changed(transition)
    case transition.event
    when :publish
      track_event('JO02_Save') if self.published_at.nil?
      self.published_at = DateTime.now
    when :submit
      if self.submited_at.nil?
        track_event('JO03_Submit')
      else
        track_event('JO05c_Resubmit')
        ClientMailer.delay.updated_job_offer(self)
      end
      self.submited_at = DateTime.now
      self.published_at ||= DateTime.now
      set_client_discount!
    when :pay
      track_event('JO04_Pay')
      self.paid_at = DateTime.now
      ClientMailer.delay.new_job_offer(self)
    when :accept
      track_event('JO05b_Accepted')
      self.approved_at = DateTime.now
    when :reject
      track_event('JO05a_Rejected', job_offer_rejected_reason: self.review_comment)
      self.rejected_at = DateTime.now
    when :mark_as_sent
      track_event('JO06_Sent')
      self.sent_at = DateTime.now
    when :archive
      track_event('JO07a_Archive')
      self.archived_at = DateTime.now
    when :rate
      track_event('JO08_Rate')
      self.rated_at = DateTime.now
    when :refund
      self.refund_origin = transition.from_name
      track_event('JOXX_Refunded', refund_origin: refund_origin)
      self.refunded_at = DateTime.now
    end
    self.dead = false
    save!
  end

  def process_skills
    self.skills.reject!(&:blank?) if self.skills_changed?
    self.skills.map!(&:to_sym)
  end

  def set_client_attributes
    if location_changed? || company_name_changed? || company_url_changed? || company_description_changed?
      self.client.location = self.location
      self.client.company_name = self.company_name
      self.client.company_url = self.company_url
      self.client.company_description = self.company_description
      self.client.save!
    end
  end

end
