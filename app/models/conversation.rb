class Conversation

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to  :client
  belongs_to  :designer
  belongs_to  :job_offer
  belongs_to  :designer_reply
  embeds_many :messages, cascade_callbacks: true

  validates_presence_of :client_id, :designer_id, :job_offer_id, :designer_reply_id

  accepts_nested_attributes_for :messages

  before_validation :set_ids

  def designer_reply
    DesignerReply.find(self.designer_reply_id)
  end

  protected

  def set_ids
    if designer_reply
      self.job_offer = designer_reply.job_offer
      self.client = job_offer.client
      self.designer = designer_reply.designer
    end
  end

end