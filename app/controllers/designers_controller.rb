class ::DesignersController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  before_filter :set_section

  def index
    track_event("Viewing ::Designers")
    @skill = params[:skill].try(:to_sym)
    index!
  end

  def map
    track_event("Viewing ::Designer Map")
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
        if current_user.id == @designer.id
          sign_in 'user', @designer, bypass: true
        end
        redirect_to edit_designer_path(@designer)
      end
      failure.html do
        if current_user.id == @designer.id
          @designer.clean_up_passwords
        end
        render :edit
      end
    end
  end

  def reapply
    if @designer.status != :rejected
      redirect_to edit_designer_path(@designer)
      return
    end
    @designer.applied_at = DateTime.now
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

  def show
    @microdata = { itemscope: true, itemtype: "http://data-vocabulary.org/Person" }
    @title_microdata = { itemprop: 'name' }
    show!
  end

  protected

  def collection
    @designers = ::Designer.page(params[:page]).per(10).order_by(created_at: :desc)

    if current_user && (current_user.is_a?(Admin) || current_user.is_a?(Client))
      @designers = @designers.accepted.public_private
    else
      @designers = @designers.accepted.public_only
    end

    unless params[:skill].blank?
      @designers = @designers.for_skill(params[:skill])
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
