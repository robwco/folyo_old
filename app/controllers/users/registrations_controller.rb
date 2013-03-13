#see http://stackoverflow.com/questions/5908921/rails-devise-redirecting-when-editing-updating-a-user-with-error
#and https://github.com/plataformatec/devise/wiki/How-To:-Customize-the-redirect-after-a-user-edits-their-profile
#and https://github.com/plataformatec/devise/wiki/How-To%3a-Allow-users-to-edit-their-account-without-providing-a-password

class Users::RegistrationsController < Devise::RegistrationsController
  def new
    # make sure new users are not redirected to some random page
    session.delete :previous_url
    case params[:initial_role]
    when 'designer'
      @user = Designer.new
      track_event("Viewing #{params[:initial_role]} Sign Up")
      respond_with_navigational(resource){ render "new_#{params[:initial_role]}" }
    when 'client'
      @user = Client.new
      if params[:job]
        track_event("Viewing #{params[:initial_role]} Sign Up (Job)")
        respond_with_navigational(resource) { render "new_job" }
      else
        track_event("Viewing #{params[:initial_role]} Sign Up")
        respond_with_navigational(resource){ render "new_#{params[:initial_role]}" }
      end
    else
      redirect_to :root
    end
  end

  # POST /resource
  # note: create method copied from the normal Devise one
  def create
    @user = case params[:user][:initial_role]
    when 'designer'
      Designer.new(params[:user])
    when 'client'
      Client.new(params[:user])
    end
    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        # respond_with resource, :location => redirect_location(resource_name, resource)

        track_event("Signed Up", role: params[:user][:initial_role])

        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :inactive_signed_up, :reason => inactive_reason(resource) if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      case params[:user][:initial_role]
      when 'designer'
        respond_with_navigational(resource) { render "new_#{resource.initial_role}" }
      when 'client'
        respond_with_navigational(resource) { render "new_job" }
      else
        respond_with_navigational(resource) { render "new_#{resource.initial_role}" }
      end
    end
  end

  def update
    # Override Devise to use update_attributes instead of update_with_password.
    # This is the only change we make.
    if resource.update_attributes(params[resource_name])
      set_flash_message :notice, :updated
      # Line below required if using Devise >= 1.2.0
      sign_in resource_name, resource, :bypass => true
      redirect_to after_update_path_for(resource)
    else
      clean_up_passwords(resource)
      render :edit
    end

    params[resource_name].delete(:password) if params[resource_name][:password].blank?
    params[resource_name].delete(:password_confirmation) if params[resource_name][:password_confirmation].blank?
  end

  protected

  def after_update_path_for(resource)
    edit_user_registration_path(resource)
  end

  def after_sign_up_path_for(resource)
    if current_user.is_a? Designer
      designer_offers_path(signup: true)
    elsif current_user.is_a? Client
      new_offer_path(signup: true)
    end
  end
end

