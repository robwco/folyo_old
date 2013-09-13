class DesignerProjectsController < ApplicationController

  before_filter :set_designer, :set_section

  inherit_resources

  load_and_authorize_resource

  def new
    @designer_project = @designer.projects.create
    redirect_to edit_designer_project_path(@designer, @designer_project)
  end

  def update
    update! { edit_designer_project_path(@designer, @designer_project)}
  end

  def upload_status
    respond_to do |format|
      format.json { render json: { complete: @designer_project.all_artworks_processed? } }
    end
  end

  protected

  def set_designer
    @designer ||= if params[:designer_id]
       Designer.find(params[:designer_id])
    elsif current_user.is_a?(Designer)
      current_user
    else
      nil
    end
  end

  def collection
    if @designer
      @designer_projects = @designer.projects.page(params[:page]).per(10)
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