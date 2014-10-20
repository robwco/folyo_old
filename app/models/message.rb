class Message

  include Mongoid::Document
  include Mongoid::Timestamps
  include Sidekiq::Delay
  include Mongoid::EmbeddedFindable

  field :text, type: String

  embedded_in :conversation
  belongs_to  :author, class_name: 'User'

  default_scope -> { order_by(created_at: :asc) }

  validates_presence_of :author_id, :text

  after_create :send_notification!, :track_event

  def self.find(id)
    find_through(Conversation, :messages, id)
  end

  def recipient
    if self.author == conversation.client
      conversation.designer
    elsif self.author == conversation.designer
      conversation.client
    else
      nil
    end
  end

  def author_kind
    if self.author == conversation.client
      :client
    elsif self.author == conversation.designer
      :designer
    end
  end

  protected

  def send_notification!
    MessageMailer.sidekiq_delay.send_message(self.id)
  end

  def track_event
    author.track_user_event('New message', {author: author.id, author_name: author.full_name, recipient: recipient.id, recipient_name: recipient.full_name, text: text})
  end

end