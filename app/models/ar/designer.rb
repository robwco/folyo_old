class AR::Designer < ActiveRecord::Base

  self.table_name = 'designers'

  include ActiveModel::Dirty

  belongs_to :user
  belongs_to :status
  belongs_to :profile_type

  has_and_belongs_to_many :skills

  has_many :designer_posts

  validates_presence_of :portfolio_url
  validates_format_of :portfolio_url, :with => URI::regexp(%w(http https))

  ## scopes ##
  scope :ordered, :order => 'created_at DESC'
  scope :ordered_by_status, :order => 'status_id ASC, created_at DESC'

  scope :pending, where(:status_id => '1')
  scope :rejected, where(:status_id => '2')
  scope :accepted, where(:status_id => '3')

  scope :public_only, where(:profile_type_id => '1')
  scope :public_private, where('profile_type_id=1 OR profile_type_id=2')

  # scope :san_francisco, where(:location => 'San Francisco')
  scope :san_francisco, :conditions => ["location LIKE ?", '%San Francisco%']
  scope :palo_alto, where(:location => 'Palo Alto')
  scope :cupertino, where(:location => 'Cupertino')

  ## callbacks ##
  before_update :tweet_out, :accept_reject_mailer


  def role_name
    'designer'
  end

  def tweet_out
    if Rails.env.production? && self.status_id_changed? && self.profile_type_id==1 && self.status_id==3 && !self.twitter_username.blank?
      Twitter.update("Welcome to @#{self.twitter_username}! Check out their profile here: http://www.folyo.me/designers/#{self.id}")
    end
  end

  def accept_reject_mailer
    if self.status_id_changed?
      if self.status_id==3
        DesignerMailer.accepted_mail(self).deliver
      elsif self.status_id==2
        DesignerMailer.rejected_mail(self).deliver
      end
    end
  end

  def accepted?
      self.status.name=="Accepted"
  end

  def status?(status_name)
    self.status.name.downcase==status_name.to_s
  end

  def email
    self.user.email
  end
end
