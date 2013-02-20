class AR::Message < ActiveRecord::Base

  self.table_name = 'messages'

  ## associations ##
  belongs_to :from_user, :class_name => "AR::User", :foreign_key => "from_user_id"
  belongs_to :to_user, :class_name => "AR::User", :foreign_key => "to_user_id"

  ## validations ##
  validates_presence_of :from_user, :to_user, :comment

  ## callbacks ##
  after_create :send_notification!

  ## scopes ##
  scope :ordered, :order => 'created_at DESC'

  ## behaviors ##
  # acts_as_readable
  # https://github.com/tjackiw/acts-as-readable

  ## methods ##

  def send_notification!
    MessageMailer.send_message(self).deliver
  end

end
