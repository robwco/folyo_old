# encoding: UTF-8

module ApplicationHelper

  def current_link_to(title, target, link_class='')
    # see http://www.liquidfoot.com/2010/09/28/add-highlight-link-to-current-page-in-rails/
    # and http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to_unless_current

    link_to_unless_current title, target do
      link_to title, target, class: "current #{link_class}"
    end
  end

  def current_link_to_unless(condition, title, target, link_class='')
    link_to_unless condition, title, target do
      link_to title, target, class: "current #{link_class}"
    end
  end

  def section_link_to(title, target, section)
    if section == @section || (section.is_a?(Array) && section.include?(@section))
      link_to title, target, class: 'current'
    else
      link_to title, target
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

  def error_messages(objects, resource_name = nil)
    # this method can be either applied to a single object or an array of objects
    objects = [objects] unless objects.is_a?(Enumerable)

    return "" if objects.all?{|o| o.errors.empty?}

    messages = objects.map {|o| o.errors.full_messages.map { |msg| content_tag(:li, msg) }}.flatten
    sentence = I18n.t("errors.messages.not_saved", count: messages.length, resource: resource_name || objects.first.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation">
      <h2>#{sentence}</h2>
      <ul>#{messages.join}</ul>
    </div>
    HTML

    html.html_safe
  end

  def markdown_renderer
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, space_after_headers: true)
  end

  def format_text(model, attribute, options = {})
    html = markdown_renderer.render(model.send(attribute)) rescue ''
    if options[:sanitize]
      Sanitize.clean(html)
    else
      html
    end
  end

  def textarea_type(model)
    if model.send(:text_format) == :markdown
      'markdown'
    else
      'wysiwyg'
    end
  end

  private


end
