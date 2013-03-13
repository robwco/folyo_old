class JobOffer

  include Mongoid::Document
  include Mongoid::Timestamps

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
    ["Under $1000", "$1000-$1500", "$1500-$2000", "$2000-$3000", "$3000-$4000", "$4000-$5000", "$5000-$6000", "$6000-$7500", "$7500-$10000", "$10000-$15000", "$15000-$20000", "$20000+"]
  end

  def self.budget_types
    [:low, :medium, :high]
  end

  ## validations ##
  validates_presence_of     :title, :full_description
  validates_numericality_of :compensation, :allow_nil => true
  validates_inclusion_of    :coding,       in: JobOffer.coding_options, allow_blank: true
  validates_inclusion_of    :budget_range, in: JobOffer.budget_ranges,  allow_blank: true
  validates_inclusion_of    :budget_type,  in: JobOffer.budget_types,   allow_blank: true
  validates                 :skills, length: { minimum: 1, message: 'select 1 skill at least' }, array: { inclusion: { in: Designer.skills.map(&:to_s)} }

  ## callbacks ##
  before_validation :remove_empty_skills
  before_create     :set_sent_out_at
  after_create      :send_offer_notification, :new_job_offer_event, :track_creation_event
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

  def get_budget_type(index)
    if index.nil?
      return "Medium"
    else
      return Array["Low", "Medium", "High"][index-1]
    end
  end

  def client_email
    self.client.email
  end

  # archive the offer and mark some designer replies as picked
  def archive!(picked_designer_id = nil, send_email = true)
    self.status = :archived
    save!

    self.designer_replies.each do |reply|
      if reply.user_id == picked_designer_id.to_i
        reply.picked = true
      else
        reply.picked = false
        if send_email
          DesignerMailer.rejected_reply(reply.designer, self).deliver
        end
      end
      reply.save!
    end
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

  protected

  def sanitize_attributes
    %w(full_description).each do |attribute|
      self.send(:"#{attribute}=", Sanitize.clean(self.send(attribute.to_sym), Sanitize::Config::BASIC))
    end
  end

  def new_job_offer_event
    # self.client.track_user_action("New Job Offer", {:job_offer_title => self.title, :job_offer_id => self.id})
  end

  def send_offer_notification
    ClientMailer.new_job_offer(self).deliver
  end

  def status_changed
    event = "Not Modified"
    if self.status_changed?
      case self.status
      when :accepted
        self.approved_at = Time.now
        event = "Accepted"
        ClientMailer.job_offer_accepted_mail(self).deliver
      when :rejected
        event = "Rejected"
      when :paid
        self.paid_at = Time.now
        event = "Paid"
      when :archived
        self.archived_at = Time.now
        event = "Archived"
      when :refunded
        self.refunded_at = Time.now
        event = "Refunded"
      end
      self.client.track_user_action("Job Offer #{event}", {job_offer_id: self.id, job_offer_title: self.title})
    end
  end

  def set_sent_out_at
    self.sent_out_at = Time.now
  end

  def track_creation_event
    # track_event 'New Job Offer', mp_note: title, job_offer_title: title, job_offer_id: id
  end

  def remove_empty_skills
    self.skills.reject!(&:blank?) if self.skills_changed?
  end

end