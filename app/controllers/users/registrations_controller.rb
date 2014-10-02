#see http://stackoverflow.com/questions/5908921/rails-devise-redirecting-when-editing-updating-a-user-with-error
#and https://github.com/plataformatec/devise/wiki/How-To:-Customize-the-redirect-after-a-user-edits-their-profile
#and https://github.com/plataformatec/devise/wiki/How-To%3a-Allow-users-to-edit-their-account-without-providing-a-password

class Users::RegistrationsController < Devise::RegistrationsController

  section :account

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
      set_referral_fields(@user)
      @section = :post_job
      track_event("Viewing #{params[:initial_role]} Sign Up")
      respond_with_navigational(resource){ render "new_#{params[:initial_role]}" }
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
      client = Client.new(params[:user])
      set_referral_fields(client)
      client
    end
    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :inactive_signed_up, :reason => inactive_reason(resource) if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      resource.errors.messages.delete(:paypal_email) if params[:user][:initial_role] == 'designer'
      clean_up_passwords(resource)
      respond_with_navigational(resource) { render "new_#{resource.initial_role}" }
    end
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

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
    if params[:offer_id].blank?
      edit_user_registration_path
    else
      edit_user_registration_path(offer_id: params[:offer_id])
    end
  end

  def after_sign_up_path_for(resource)
    if resource.role == 'designer'
      offers_path(signup: true)
    elsif resource.role == 'client'
      new_offer_path(signup: true)
    end
  end

  def set_referral_fields(resource)
    if token = session[:referral_token]
      if program = ReferralProgram.where(token: token).first
        resource.referring_program = program
        resource.next_offer_discount = program.discount
      elsif designer = Designer.where(referral_token: token).first
        resource.referring_designer = designer
      end
    end
  end
end
