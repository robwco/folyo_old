class Admin < User

  trackable :email, :full_name, :role, :created_at

  def role_name
    'admin'
  end

  def profile_url
    "N/A"
  end

end