class Client < User

  field :twitter_username,    type: String

  field :location,            type: String
  field :company_name,        type: String
  field :company_url,         type: String
  field :company_description, type: String

  field :next_offer_discount, type: Integer

  has_many :job_offers, validate: false

  validates_inclusion_of :next_offer_discount, in: 1..100, allow_nil: true, message: 'must be between 1 and 100'

  belongs_to  :referring_designer, class_name: 'Designer'

  def role_name
    'client'
  end

  def profile_url
    "http://www.folyo.me/clients/#{self.to_param}"
  end

  def track_signup_event
    track_user_event('Signup Client')
  end

  def vero_attributes
    { email: self.email, full_name: self.full_name, role: self.role, company_name: self.company_name, slug: self.slug, created_at: self.created_at }
  end

  def update_vero_attributes
    if company_name_changed? || email_changed? || full_name_changed?
      vero.users.edit_user!(id: self.id.to_s, changes: {email: self.email, full_name: self.full_name, slug: self.slug, company_name: self.company_name})
    end
  end

  def update_intercom_attributes
    user = Intercom::User.find(user_id: self.id) rescue Intercom::User.new
    user.user_id = self.id.to_s
    user.email = self.email
    user.name = self.full_name
    user.created_at = self.created_at
    user.custom_data = {
      role: 'client',
      slug: self.slug,
      company_name: self.company_name
    }
    user.save
  end

end