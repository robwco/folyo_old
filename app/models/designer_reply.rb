class DesignerReply

  include Mongoid::Document
  include Mongoid::Timestamps

  field :message,    type: String
  field :collapsed,  type: Boolean
  field :picked,     type: Boolean, default: false
  field :evaluation, type: String

  field :pg_id

  ## associations ##
  embedded_in :job_offer
  belongs_to  :designer

  ## validations ##
  validates_presence_of :job_offer, :designer
  validates_length_of   :message, maximum: 300

  ## callbacks ##
  after_create :send_notification!, :track_event

  ## scopes ##
  scope :ordered, order_by(created_at: :desc)

  def send_notification!
    # indirection here because we cannot directly use an embedded instance with delayed_job
    job_offer.delay.send_job_offer_reply_notification(self.id)
  end

  def text_format
    :markdown
  end

  def track_event
    self.designer.track_user_event('Job Offer Reply',
      job_offer_title:    job_offer.title,
      job_offer_id:       job_offer.id,
      message:            message
    )
  end

end