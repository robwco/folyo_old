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

end