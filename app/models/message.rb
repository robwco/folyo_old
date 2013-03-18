class Message

  include Mongoid::Document
  include Mongoid::Timestamps

  field :comment, type: String

  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user,   class_name: 'User'

  ## validations ##
  validates_presence_of :from_user_id, :to_user_id, :comment

  ## callbacks ##
  after_create :send_notification!, :track_event

  ## scopes ##
  scope :ordered, order_by(:created_at => :desc)

  protected

  def send_notification!
    MessageMailer.send_message(self).deliver
  end

  def track_event
    from_user.track_user_action("New message", {:from_user => from_user.id, :from_user_name => from_user.full_name, :to_user_id => to_user.id, :to_user_name => to_user.full_name})
  end

end