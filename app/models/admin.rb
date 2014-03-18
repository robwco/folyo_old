class Admin < User

  def role_name
    'admin'
  end

  def profile_url
    "N/A"
  end

  def vero_attributes
    {}
  end

  def update_intercom_attributes(force = false, by_email = false)
    if force || email_changed? || full_name_changed?
      user = by_email ? Intercom::User.find(email: self.email) : Intercom::User.find(user_id: self.id) rescue Intercom::User.new
      user.user_id = self.id.to_s
      user.email = self.email
      user.name = self.full_name
      user.created_at = self.created_at
      user.custom_data = {
        type: 'admin',
        slug: self.slug
      }
      user.save
    end
  end

end