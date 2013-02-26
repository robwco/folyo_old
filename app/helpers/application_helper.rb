module ApplicationHelper

  def current_link_to(title, target)
    # see http://www.liquidfoot.com/2010/09/28/add-highlight-link-to-current-page-in-rails/
    # and http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to_unless_current
    link_to_unless_current title, target do
      link_to title, target, :class => "current"
    end
  end

  def first_words(s, n)
    if s
      a = s.split(/\s/) # or /[ ]+/ to only split on spaces
      a[0...n].join(' ') + (a.size > n ? '...' : '')
    end
  end

  def render_site_nav
    if current_user
      if current_user.is_a? Designer
        render '/designers/top_bar'
      elsif current_user.is_a? Client
        render '/clients/top_bar'
      elsif current_user.is_a? Admin
        render '/admin/top_bar'
      else
        render '/site/top_bar'
      end
    else
      render '/site/top_bar'
    end
  end

  def avatar_url(user)
    default_url = request.protocol+request.host_with_port+asset_path('default-avatar.png')
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=120&d=#{CGI.escape(default_url)}"
  end

  def sym_label_method
    ->(sym){sym.to_s.humanize}
  end

end
