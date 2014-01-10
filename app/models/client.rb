class Client < User

  field :twitter_username,    type: String

  field :location,            type: String
  field :company_name,        type: String
  field :company_url,         type: String
  field :company_description, type: String

  field :next_offer_discount, type: Integer

  has_many :job_offers

  validates_inclusion_of :next_offer_discount, in: 1..100, allow_nil: true, message: 'must be between 1 and 100'

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
    {id: id.to_s, email: self.email, full_name: self.full_name, role: self.role, company_name: self.company_name, slug: self.slug, created_at: self.created_at}
  end

  def update_vero_attributes
    if company_name_changed? || email_changed? || full_name_changed?
      vero.users.edit_user!(id: self.id.to_s, changes: {email: self.email, full_name: self.full_name, slug: self.slug, company_name: self.company_name})
    end
  end

end