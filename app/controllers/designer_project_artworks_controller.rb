class DesignerProjectArtworksController < ApplicationController

  before_filter :set_designer, :set_project

  inherit_resources
  defaults resource_class: DesignerProjectArtwork, collection_name: 'artworks'

  respond_to :json, only: :create

  def create
    create! do |format|
      format.json { render json: {polling_path: upload_status_designer_project_path(@designer, @designer_project)} }
    end
  end

  def index
    render partial: 'designer_projects/artworks', locals: { project: @designer_project }
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

  protected

  def set_project
    @designer_project = @designer.projects.find(params[:project_id])
  end

  def begin_of_association_chain
    @designer_project
  end

end