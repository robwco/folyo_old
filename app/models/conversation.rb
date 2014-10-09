class Conversation

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to  :client
  belongs_to  :designer
  belongs_to  :job_offer
  belongs_to  :designer_reply
  embeds_many :messages

  validates_presence_of :client_id, :designer_id, :job_offer_id, :designer_reply_id

end