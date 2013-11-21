class DesignerProjectArtworksController < ApplicationController

  before_filter :set_designer, :set_project
  before_filter :set_artwork, only: [:edit_cover, :update_cover]

  inherit_resources
  defaults resource_class: DesignerProjectArtwork, collection_name: 'artworks'

  respond_to :json, only: :create

  def create
    create! do |format|
      format.json { render json: {polling_path: upload_status_designer_project_path(@designer, @designer_project)} }
    end
  end

  def index
    render partial: 'designer_projects/artworks', locals: { project: @designer_project, artwork: @designer_project.artworks.processed.first }
  end

  def edit_cover
    render layout: false
  end

  def update_cover
    @designer_project.artworks.update_all(is_cover: false)
    @artwork.crop_cover(
      params[:designer_project_artwork][:crop_x],
      params[:designer_project_artwork][:crop_y],
      params[:designer_project_artwork][:crop_w],
      params[:designer_project_artwork][:crop_h]
    )
    redirect_to edit_cover_designer_project_artwork_path(@designer, @designer_project, @artwork)
  end

  def destroy
    destroy!(notice: 'Artwork was successfully removed') { edit_designer_project_path(@designer, @designer_project) }
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

  def set_artwork
    @artwork = @designer_project.artworks.find(params[:id])
  end

  def begin_of_association_chain
    @designer_project
  end

end