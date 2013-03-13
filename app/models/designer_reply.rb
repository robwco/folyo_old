class DesignerReply

  include Mongoid::Document
  include Mongoid::Timestamps

  field :message,    type: String
  field :collapsed,  type: Boolean
  field :picked,     type: Boolean
  field :evaluation, type: String

  field :pg_id

  ## associations ##
  embedded_in :job_offer
  belongs_to  :designer

  ## validations ##
  validates_presence_of :job_offer, :designer

  ## callbacks ##
  after_create :send_notification!

  ## scopes ##
  scope :ordered, order_by(created_at: :desc)

  def send_notification!
    ClientMailer.job_offer_replied(self).deliver
  end

end