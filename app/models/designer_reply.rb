class DesignerReply

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::EmbeddedFindable

  field :message,    type: String
  field :collapsed,  type: Boolean
  field :picked,     type: Boolean, default: false
  field :evaluation, type: String
  field :status,     type: Symbol, default: :default

  ## associations ##
  embedded_in :job_offer
  belongs_to  :designer

  ## validations ##
  validates_presence_of :job_offer, :designer
  validates_length_of   :message, minimum: 30, maximum: 350, tokenizer: lambda { |str| str.scan(/./) }

  ## callbacks ##
  after_create :send_creation_notification!, :track_creation_event
  after_update :track_update_event, if: :message_changed?

  ## scopes ##
  default_scope -> { order_by(created_at: :desc) }
  scope :shortlisted, -> { where(status: :shortlisted) }
  scope :hidden,      -> { where(status: :hidden) }
  scope :default,     -> { where(status: :default) }
  scope :with_status,   ->(status) {
    status ||= :default
    status = status.to_sym
    status == :all ? all : where(status: status)
  }

  def self.find(id)
    find_through(JobOffer, :designer_replies, id)
  end

  def send_creation_notification!
    ClientMailer.job_offer_replied(self).deliver
  end

  def track_creation_event
    self.designer.track_user_event('Job Offer Reply',
      job_offer_title:    job_offer.title,
      job_offer_id:       job_offer.id,
      message:            message
    )
  end

  def track_update_event
    self.designer.track_user_event('Job Offer Reply Updated',
      job_offer_title:    job_offer.title,
      job_offer_id:       job_offer.id,
      message:            message
    )
  end

  def next(status = nil)
    job_offer.designer_replies.with_status(status).order_by(created_at: :desc).where(:created_at.lt => self.created_at)
  end

  def previous(status = nil)
    job_offer.designer_replies.with_status(status).order_by(created_at: :desc).where(:created_at.gt => self.created_at)
  end

  def self.deduplicate_for_offer(offer)
    DesignerReply.skip_callback(:create, :after, :send_creation_notification!)
    DesignerReply.skip_callback(:create, :after, :track_creation_event)

    replies = offer.designer_replies.uniq.map(&:clone)
    offer.designer_replies.delete_all
    offer.designer_replies = replies
    offer.save

    DesignerReply.set_callback(:create, :after, :track_creation_event)
    DesignerReply.set_callback(:create, :after, :send_creation_notification!)
    true
  end

  def hidden?
    self.status == :hidden
  end

  def shortlisted?
    self.status == :shortlisted
  end

  def toggle_hidden!(new_status = nil)
    new_status = new_status.nil? ? (self.status == :hidden ? :default : :hidden) : (new_status ? :hidden : :default)
    self.update_attribute(:status, new_status)
    new_status
  end

  def toggle_shortlisted!(new_status = nil)
    new_status = new_status.nil? ? (self.status == :shortlisted ? :default : :shortlisted) : (new_status ? :shortlisted : :default)
    self.update_attribute(:status, new_status)
    new_status
  end

end