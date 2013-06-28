class JobOffer

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

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
  field :coding,              type: Symbol
  field :budget_range,        type: String
  field :budget_type,         type: Symbol,   default: :medium
  field :skills,              type: Array,    default: []

  field :discount,            type: String
  field :discount_amount,     type: Integer

  field :is_open,             type: Boolean,  default: true
  field :status,              type: Symbol
  field :review_comment,      type: String

  field :published_at,        type: DateTime
  field :approved_at,         type: DateTime
  field :rejected_at,         type: DateTime
  field :paid_at,             type: DateTime
  field :archived_at,         type: DateTime
  field :refunded_at,         type: DateTime

  slug :title, history: true

  field :pg_id # id in postgresql. Will be removed someday

  ## associations ##
  belongs_to  :client
  embeds_many :designer_replies
  embeds_one  :order

  ## Reference data ##

  def self.coding_options
    [:not_needed, :optional, :mandatory]
  end

  def self.budget_ranges
    ['I need help to set a budget' ,'Under $1000', '$1000-$1500', '$1500-$2000', '$2000-$3000', '$3000-$4000', '$4000-$5000', '$5000-$6000', '$6000-$7500', '$7500-$10000', '$10000-$15000', '$15000-$20000', '$20000+']
  end

  def self.work_types
    [:freelance, :full_time]
  end

  def self.location_types
    [:local, :remote]
  end

  def self.budget_types
    [:low, :medium, :high]
  end

  def price
    10000
  end

  ## validations ##
  validates_presence_of     :title, :project_summary
  validates_presence_of     :project_details, unless: :persisted?
  validates_presence_of     :review_comment,  if: 'self.status == :rejected'
  validates_numericality_of :compensation, :allow_nil => true
  validates_inclusion_of    :coding,        in: JobOffer.coding_options, allow_blank: true
  validates_inclusion_of    :work_type,     in: JobOffer.work_types,     allow_blank: true
  validates_inclusion_of    :location_type, in: JobOffer.location_types, allow_blank: true
  validates                 :skills, length: { minimum: 1, message: 'Select at least one skill' }, array: { inclusion: { in: Designer.skills } }
  validates_inclusion_of    :budget_range,  in: JobOffer.budget_ranges,  allow_blank: false
  validates_inclusion_of    :budget_type,   in: JobOffer.budget_types,   allow_blank: true


  ## callbacks ##
  before_validation :process_skills
  after_create      :send_offer_notification, :track_event

  ## scopes ##
  # TODO: still need to put null values at the end
  scope :ordered, order_by(refunded_at: :desc, archived_at: :desc, paid_at: :desc, approved_at: :desc, created_at: :desc)
  scope :ordered_by_status, order_by(status: :asc)

  scope :initialized,         where(status: :initialized)
  scope :waiting_for_payment, where(status: :waiting_for_payment)
  scope :waiting_for_review,  where(status: :waiting_for_review)
  scope :accepted,            where(status: :accepted)
  scope :rejected,            where(status: :rejected)
  scope :archived,            where(status: :archived)
  scope :refunded,            where(status: :refunded)
  scope :for_designer, ->(designer) { elem_match(designer_replies: {designer_id: designer.id}) }

  ## indexes ##
  index pg_id: 1

  ## state machine ##

  state_machine :status, initial: :initialized do

    event :publish do
      transition :initialized => :waiting_for_payment
      transition :rejected    => :waiting_for_review
      transition :any         => same
    end

    event :pay do
      transition :waiting_for_payment => :waiting_for_review
    end

    event :accept do
      transition :waiting_for_review => :accepted
    end

    event :reject do
      transition :waiting_for_review => :rejected
    end

    event :archive do
      transition :accepted => :archived
    end

    event :refund do
      transition :accepted => :refunded
      transition :rejected => :initialized
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
    [:accepted, :archived, :refunded].include? self.status
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

  def reject(review_comment)
    self.review_comment = review_comment
    fire_events(:reject)
  end

  def refund
    if order.refund
      fire_events(:refund)
    end
  end

  def send_job_offer_reply_notification(reply_id)
    reply = self.designer_replies.find(reply_id)
    ClientMailer.job_offer_replied(reply).deliver
  end

  protected

  def track_event
    self.client.track_user_event("New Job Offer", job_offer_title: self.title, job_offer_id: self.id)
  end

  def send_offer_notification
    ClientMailer.delay.new_job_offer(self)
  end

  def status_changed(transition)
    event_options = { job_offer_id: self.id, job_offer_title: self.title, company_name: self.client.company_name }
    event_name = "#{transition.event.to_s}ed"
    case transition.event
    when :publish
      self.published_at = Time.now
      event_options[:action_link] = offer_order_url(self)
    when :pay
      self.paid_at = Time.now
      event_name = 'paid'
    when :accept
      self.approved_at = Time.now
      event_options[:action_link] = show_archive_offer_url(self)
    when :reject
      self.rejected_at = Time.now
      event_options[:action_link] = edit_offer_url(self)
    when :archive
      self.archived_at = Time.now
      event_name = 'archived'
    when :refund
      self.refunded_at = Time.now
      event_name = 'refunded'
    end
    save!
    self.client.track_user_event("Job Offer #{event_name.capitalize}", event_options)
  end

  def process_skills
    self.skills.reject!(&:blank?) if self.skills_changed?
    self.skills.map!(&:to_sym)
  end

  def text_format
    :markdown
  end

end
