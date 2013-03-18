class AR::JobOffer < ActiveRecord::Base

  self.table_name = 'job_offers'

  ## associations ##
  belongs_to              :client
  belongs_to              :work_type
  belongs_to              :location_type
  belongs_to              :status
  has_and_belongs_to_many :skills
  has_many                :designer_replies
  has_one                 :order
  has_many                :evaluations

  ## validations ##
  #note: should also validate presence of :client, but I temporarily removed it to fix sign up
  validates_presence_of     :title, :full_description, :skills
  validates_numericality_of :compensation, :allow_nil => true

  ## behaviours ##
  # acts_as_commentable

  ## callbacks ##
  before_save   :sanitize_attributes
  before_update :test_if_status_changed
  after_create  :send_offer_notification, :track_event

  # status foreign keys
  class Status_Keys
    PENDING  = 1
    REJECTED = 2
    ACCEPTED = 3
    PAID     = 4
    ARCHIVED = 5
    REFUNDED = 6
  end

  # status foreign keys
  class Coding_Keys
    NOT_NEEDED = 1
    OPTIONAL   = 2
    MANDATORY  = 3
  end

  ## scopes ##
  scope :ordered, :order => 'refunded_at IS NULL, refunded_at DESC, archived_at IS NULL, archived_at DESC, paid_at IS NULL, paid_at DESC, approved_at IS NULL, approved_at DESC, created_at IS NULL, created_at DESC'
  scope :ordered_by_status, :order => 'status_id ASC, created_at DESC'
  scope :pending, where(:status_id => Status_Keys::PENDING)
  scope :rejected, where(:status_id => Status_Keys::REJECTED)
  scope :accepted, where(:status_id => Status_Keys::ACCEPTED)
  scope :paid, where(:status_id => Status_Keys::PAID)
  scope :archived, where(:status_id => Status_Keys::ARCHIVED)
  scope :refunded, where(:status_id => Status_Keys::REFUNDED)


  ## methods ##

  def get_budget_type(index)
    if index.nil?
      return "Medium"
    else
      return Array["Low", "Medium", "High"][index-1]
    end
  end

  def client_email
    self.client.user.email
  end

  # archive the offer and mark some designer replies as picked
  def archive!(picked_designer_id = nil, send_email = true)
    self.status_id = Status_Keys::ARCHIVED
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
    [Status_Keys::PAID, Status_Keys::ARCHIVED, Status_Keys::REFUNDED].include? self.status_id
  end

  protected

  def sanitize_attributes
    %w(full_description).each do |attribute|
      self.send(:"#{attribute}=", Sanitize.clean(self.send(attribute.to_sym), Sanitize::Config::BASIC))
    end
  end

  def accepted?
    self.status_id == Status_Keys::ACCEPTED
  end

  def archived?
    self.status_id == Status_Keys::ARCHIVED
  end

  def track_event
    self.client.track_user_action("New Job Offer", job_offer_title: self.title, job_offer_id: self.id)
  end

  def send_offer_notification
    ClientMailer.new_job_offer(self).deliver
  end

  def test_if_status_changed
    event = "Not Modified"
    if self.status_id_changed?
      case self.status_id
      when Status_Keys::ACCEPTED
        self.approved_at=Time.now
        event = "Accepted"
        ClientMailer.job_offer_accepted_mail(self).deliver
      when Status_Keys::REJECTED
        event = "Rejected"
      when Status_Keys::PAID
        self.paid_at=Time.now
        event = "Paid"
      when Status_Keys::ARCHIVED
        self.archived_at = Time.now
        event = "Archived"
      when Status_Keys::REFUNDED
        self.refunded_at = Time.now
        event = "Refunded"
      end
      self.client.track_user_action("Job Offer #{event}", job_offer_id: self.id, job_offer_title: self.title)
    end
  end

end
