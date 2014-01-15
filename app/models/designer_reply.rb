class DesignerReply

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::EmbeddedFindable

  field :message,    type: String
  field :collapsed,  type: Boolean
  field :picked,     type: Boolean, default: false
  field :evaluation, type: String

  ## associations ##
  embedded_in :job_offer
  belongs_to  :designer

  ## validations ##
  validates_presence_of :job_offer, :designer
  validates_length_of   :message, maximum: 350, tokenizer: lambda { |str| str.scan(/./) }

  ## callbacks ##
  after_create :send_creation_notification!, :track_creation_event
  after_update :send_update_notification!,   :track_update_event, if: :message_changed?

  ## scopes ##
  default_scope order_by(created_at: :desc)

  def self.find(id)
    find_through(JobOffer, :designer_replies, id)
  end

  def send_creation_notification!
    ClientMailer.job_offer_replied(self).deliver
  end
  handle_asynchronously :send_creation_notification!

  def send_update_notification!
    ClientMailer.updated_reply(self).deliver
  end
  handle_asynchronously :send_update_notification!

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

  def next
    job_offer.designer_replies.where(:created_at.lt => self.created_at).first
  end

  def previous
    job_offer.designer_replies.where(:created_at.gt => self.created_at).last
  end

end