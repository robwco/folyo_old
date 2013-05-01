class JobOffer

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  # using routes for Event tracking
  include Rails.application.routes.url_helpers
  default_url_options[:host] = HOST

  field :title,            type: String
  field :full_description, type: String
  field :compensation,     type: Integer
  field :work_type,        type: Symbol
  field :location_type,    type: Symbol
  field :comp_high,        type: Integer
  field :coding,           type: Symbol
  field :budget_range,     type: String
  field :budget_type,      type: Symbol,   default: :medium
  field :skills,           type: Array

  field :discount,         type: String
  field :discount_amount,  type: Integer

  field :status,           type: Symbol,   default: :pending
  field :is_open,          type: Boolean,  default: true

  field :sent_out_at,      type: DateTime
  field :approved_at,      type: DateTime
  field :paid_at,          type: DateTime
  field :archived_at,      type: DateTime
  field :refunded_at,      type: DateTime

  slug :title, history: true

  field :pg_id # id in postgresql. Will be removed someday

  ## associations ##
  belongs_to  :client
  embeds_many :designer_replies
  embeds_one  :order

  ## Reference data ##

  def self.statuses
    [:pending, :rejected, :accepted, :paid, :archived, :refunded]
  end

  def self.coding_options
    [:not_needed, :optional, :mandatory]
  end

  def self.budget_ranges
    ["Under $1000", "$1000-$1500", "$1500-$2000", "$2000-$3000", "$3000-$4000", "$4000-$5000", "$5000-$6000", "$6000-$7500", "$7500-$10000", "$10000-$15000", "$15000-$20000", "$20000+"]
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

  ## validations ##
  validates_presence_of     :title, :full_description
  validates_numericality_of :compensation, :allow_nil => true
  validates_inclusion_of    :status,        in: JobOffer.statuses,       allow_blank: false
  validates_inclusion_of    :coding,        in: JobOffer.coding_options, allow_blank: true
  validates_inclusion_of    :work_type,     in: JobOffer.work_types,     allow_blank: true
  validates_inclusion_of    :location_type, in: JobOffer.location_types, allow_blank: true
  validates_inclusion_of    :budget_range,  in: JobOffer.budget_ranges,  allow_blank: true
  validates_inclusion_of    :budget_type,   in: JobOffer.budget_types,   allow_blank: true
  validates                 :skills, length: { minimum: 1, message: 'select 1 skill at least' }, array: { inclusion: { in: Designer.skills } }

  ## callbacks ##
  before_validation :process_skills
  before_create     :set_sent_out_at
  after_create      :send_offer_notification, :track_event
  before_save       :sanitize_attributes
  before_update     :status_changed

  ## scopes ##
  # TODO: still need to put null values at the end
  scope :ordered, order_by(refunded_at: :desc, archived_at: :desc, paid_at: :desc, approved_at: :desc, created_at: :desc)
  scope :ordered_by_status, order_by(status: :asc)

  scope :pending,  where(status: :pending)
  scope :rejected, where(status: :rejected)
  scope :accepted, where(status: :accepted)
  scope :paid,     where(status: :paid)
  scope :archived, where(status: :archived)
  scope :refunded, where(status: :refunded)
  scope :for_designer, ->(designer) { elem_match(designer_replies: {designer_id: designer.id}) }

  ## indexes ##
  index pg_id: 1

  def client_email
    self.client.email
  end

  # archive the offer and mark some designer replies as picked
  def archive!(picked_designer_id = nil, send_email = true)
    self.status = :archived
    save!

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
    save!
  end

  def live?
    [:paid, :archived, :refunded].include? self.status
  end

  def accepted?
    self.status == :accepted
  end

  def archived?
    self.status == :archived
  end

  def rejected?
    self.status == :rejected
  end

  def paid?
    self.status == :paid
  end

  def refunded?
    self.status == :refunded
  end

  def send_job_offer_reply_notification(reply_id)
    reply = self.designer_replies.find(reply_id)
    ClientMailer.job_offer_replied(reply).deliver
  end

  protected

  def sanitize_attributes
    %w(full_description).each do |attribute|
      self.send(:"#{attribute}=", Sanitize.clean(self.send(attribute.to_sym), Sanitize::Config::BASIC))
    end
  end

  def track_event
    self.client.track_user_event("New Job Offer", job_offer_title: self.title, job_offer_id: self.id)
  end

  def send_offer_notification
    ClientMailer.delay.new_job_offer(self)
  end

  def status_changed
    event_name = "Not Modified"
    event_options = { job_offer_id: self.id, job_offer_title: self.title, company_name: client.company_name }
    if self.status_changed?
      case self.status
      when :accepted
        self.approved_at = Time.now
        event_name = "Accepted"
        event_options[:action_link] = offer_orders_url(self)
      when :rejected
        event_name = "Rejected"
        ClientMailer.delay.job_offer_rejected_mail(self)
      when :paid
        self.paid_at = Time.now
        event_name = "Paid"
        event_options[:action_link] = show_archive_offer_url(self)
      when :archived
        self.archived_at = Time.now
        event_name = "Archived"
      when :refunded
        self.refunded_at = Time.now
        event_name = "Refunded"
      end
      self.client.track_user_event("Job Offer #{event_name}", event_options)
    end
  end

  def set_sent_out_at
    self.sent_out_at = Time.now
  end

  def process_skills
    self.skills.reject!(&:blank?) if self.skills_changed?
    self.skills.map!(&:to_sym)
  end

end
