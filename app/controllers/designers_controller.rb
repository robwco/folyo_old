class DesignersController < ApplicationController

  inherit_resources
  load_and_authorize_resource except: :show_by_pg_id

  before_filter :set_section

  def show_by_pg_id
    @designer = Designer.where(designer_pg_id: params[:id].to_i).first
    raise Mongoid::Errors::DocumentNotFound.new(Designer, pg_id: params[:id].to_i) if @designer.nil?
    redirect_to designer_url(@designer), status: :moved_permanently
  end

  def index
    track_event("Viewing Designers")
    @skill = params[:skill].try(:to_sym)
    index!
  end

  def map
    track_event("Viewing Designer Map")
    @designers = Designer.accepted.public_only.where(:coordinates.ne => nil)
  end

  def san_francisco_bay_area
    @designers = Designer.accepted.public_only
  end

  def edit
    if @designer.is_a?(Html::Designer)
      @designer.to_markdown!
      redirect_to(edit_designer_path(@designer))
      return
    end
  end

  def update
    update! { edit_designer_path(@designer) }
  end

  def reapply
    if @designer.status != :rejected
      redirect_to edit_designer_path(@designer)
      return
    end
    if @designer.is_a?(Html::Designer)
      @designer.to_markdown!
      redirect_to(reapply_designer_path(@designer))
      return
    end
    @designer.status = :pending
    @reapplying = true
    @submit_label = 'Reapply'
    render 'edit'
  end

  protected

  def collection
    @designers = Designer.page(params[:page]).per(10).ordered_by_status

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
