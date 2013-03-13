class ApplicationController < ActionController::Base

  # see http://lyconic.com/blog/2010/08/03/dry-up-your-ajax-code-with-the-jquery-rest-plugin
  before_filter :correct_safari_and_ie_accept_headers, :store_location #, :initialize_mixpanel
  after_filter :set_xhr_flash

  protect_from_forgery

  layout 'application'

  def after_sign_in_path_for(resource)
    if session[:previous_url]
      session[:previous_url]
    elsif current_user.is_a? Designer
      designer_path(current_user)
    elsif current_user.is_a? Client
      client_path(current_user)
    else
      root_path(:signin => true)
    end
  end

  # https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-on-successful-sign-in
  def store_location
    if (["client", "clients", "designer", "designers"].include? params[:controller])
      session[:previous_url] = request.url
    end
  end

  # def after_sign_in_path_for(resource)
  #     stored_location_for(resource) || root_path
  # end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message

    unless current_user
      redirect_to :root
    else
      if current_user.is_a? Designer
        redirect_to offers_path
      elsif current_user.is_a? Client
        redirect_to offers_path
      else
        root_path
      end
    end
  end

  def check_user_access
    unless current_user
      flash[:error] = "You must be signed in to view that page"
      redirect_to "/sign_in"
      false
    else
      true
    end
  end

  def check_designer_access
    return unless check_user_access
    unless current_user.is_a?(Designer) || current_user.is_a?(Admin)
      flash[:error] = "You must be signed in as a designer to view that page"
      redirect_to client_root_path
    end
  end

  def check_client_access
    return unless check_user_access

    unless current_user.is_a?(Client) || current_user.is_a?(Admin)
      flash[:error] = "You must be signed in as a client to view that page"
      redirect_to designer_root_path
    end
  end

  def check_admin_access
    return unless check_user_access

    unless current_user.is_a? Admin
      flash[:error] = "You must be signed in as a designer to view that page"
      redirect_to root_path
    end
  end

  # see http://lyconic.com/blog/2010/08/03/dry-up-your-ajax-code-with-the-jquery-rest-plugin
  def set_xhr_flash
    flash.discard if request.xhr?
  end

  def correct_safari_and_ie_accept_headers
    ajax_request_types = ['text/javascript', 'application/json', 'text/xml']
    request.accepts.sort! { |x, y| ajax_request_types.include?(y.to_s) ? 1 : -1 } if request.xhr?
  end

  def track_event(event, properties="")

    # Mixpanel
    (session[:mixpanel_events] ||= "") << 'mixpanel.track( "'+event+'", '+properties.to_json+' );'

  end


end
