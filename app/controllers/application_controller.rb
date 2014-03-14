require "yaml_frontmatter"

class ApplicationController < ActionController::Base

  before_filter :store_location
  before_filter :set_referral_code
  after_filter  :set_xhr_flash
  helper_method :js_class_name

  protect_from_forgery

  layout 'application'

  def after_sign_in_path_for(resource)
    if session[:previous_url]
      session[:previous_url]
    elsif current_user.is_a?(Admin)
      admin_dashboard_path
    else
      offers_path
    end
  end

  # https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-on-successful-sign-in
  def store_location
    if (["client", "clients", "designer", "designers"].include? params[:controller])
      session[:previous_url] = request.url
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message

    unless current_user
      session[:previous_url] = request.path
      redirect_to sign_in_path
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
      redirect_to offers_path
    end
  end

  def check_client_access
    return unless check_user_access

    unless current_user.is_a?(Client) || current_user.is_a?(Admin)
      flash[:error] = "You must be signed in as a client to view that page"
      redirect_to offers_path
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

  def track_event(event, properties = {})
    current_user.try(:track_user_event, event, properties) unless Rails.env.test?
  end

  def self.section(section_name, params = {})
    before_filter(params) do |c|
      c.instance_variable_set(:@section, section_name.to_sym)
    end
  end

  def redirect_for_offer(job_offer, options = {})
    options.delete_if{|k,v| k.blank? }
    redirect_to case job_offer.status
    when :initialized
      edit_offer_path(job_offer, options)
    when :waiting_for_submission
      edit_offer_path(job_offer, options)
    when :waiting_for_payment
      new_offer_order_path(job_offer, options)
    when :waiting_for_review
      offer_order_path(job_offer, options)
    else
      offer_path(job_offer, options)
    end
  end

  def js_class_name
    action = case action_name
    when 'create' then 'New'
    when 'update' then 'Edit'
    else action_name
    end.camelize
    "Views.#{self.class.name.gsub('::', '.').gsub(/Controller$/, '')}.#{action}View"
  end

  def set_referral_code
    if params[:ref]
      session[:referral_token] = params[:ref]
    end
  end

end
