class DesignersController < ApplicationController

  inherit_resources
  before_filter :set_section

  def index
    track_event("Viewing Designers")
    @skill = params[:skill].try(:to_sym)
    index!
  end

  def map
    track_event("Viewing Designer Map")
    @designers = ::Designer.accepted.public_only.where(:coordinates.ne => nil)
  end

  def san_francisco_bay_area
    @designers = ::Designer.accepted.public_only
  end

  def update
    if params[:designer][:password].blank?
      params[:designer].delete("password")
      params[:designer].delete("password_confirmation")
    end
    update! do |success, failure|
      success.html do
        sign_in 'user', @designer, bypass: true
        redirect_to edit_designer_path(@designer)
      end
      failure.html do
        @designer.clean_up_passwords
        render :edit
      end
    end
  end

  def reapply
    if @designer.status != :rejected
      redirect_to edit_designer_path(@designer)
      return
    end
    @designer.status = :pending
    @reapplying = true
    @submit_label = 'Reapply'
    render 'edit'
  end

  def destroy
    sign_out(current_user)
    @designer.destroy
    redirect_to new_user_session_path, notice: 'Your account has been deleted. Hope to see you back soon!'
  end

  protected

  def collection
    @designers = ::Designer.page(params[:page]).per(10).ordered_by_status

    if current_user && (current_user.is_a?(Admin) || current_user.is_a?(Client))
      @designers = @designers.accepted.public_private
    else
      @designers = @designers.accepted.public_only
    end

    unless params[:skill].blank?
      @designers = @designers.any_in(skills: params[:skill].to_sym)
    end
  end

  def set_section
    if @designer && current_user && @designer.id == current_user.id
      @section = :account
    else
      @section = :designers
    end
  end

end
