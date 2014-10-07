class DesignerProjectsController < ApplicationController

  before_filter :set_section

  inherit_resources

  defaults resource_class: DesignerProject,
           collection_name: 'projects', route_collection_name: 'project',
           instance_name: 'project',    route_instance_name: 'project'

  belongs_to :designer

  load_and_authorize_resource

  def show
    redirect_to edit_designer_project_path(@designer, @project)
  end

  def new
    if @designer.can_create_project?
      @project = @designer.projects.create
      redirect_to edit_designer_project_path(@designer, @project)
    else
      redirect_to designer_projects_path(@designer)
    end
  end

  def update
    update! { edit_designer_project_path(@designer, @project)}
  end

  def destroy
    destroy! { designer_projects_path(@designer)}
  end

  def edit
    edit! do
      @artwork = @project.artwork
    end
  end

  protected

  def permitted_params
    params.permit!
  end

  def set_section
    if @designer && current_user && @designer.id == current_user.id
      @section = :account
    else
      @section = :designers
    end
  end

end