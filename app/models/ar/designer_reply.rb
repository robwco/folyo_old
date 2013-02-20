class AR::DesignerReply < ActiveRecord::Base

  self.table_name = 'designer_replies'

  ## associations ##
  belongs_to :job_offer
  belongs_to :user

  ## validations ##
  validates_presence_of :job_offer, :user

  ## callbacks ##
  after_create :send_notification!

  ## scopes ##
  scope :ordered, :order => 'created_at DESC'

  ## behaviors ##
  # acts_as_readable
  # https://github.com/tjackiw/acts-as-readable

  ## methods ##

  def designer
    @designer ||= self.user.designer
  end

  def send_notification!
    ClientMailer.job_offer_replied(self).deliver
  end

end
