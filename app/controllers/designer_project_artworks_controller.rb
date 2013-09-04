class DesignerProjectArtworksController < ApplicationController

  before_filter :set_designer, :set_project

  inherit_resources
  defaults resource_class: DesignerProjectArtwork, collection_name: 'artworks'

  respond_to :js, only: :create

  def create
    create! do |format|
      format.js { render text: 'ok' }
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

  protected

  def set_project
    @designer_project = @designer.projects.find(params[:project_id])
  end

  def begin_of_association_chain
    @designer_project
  end

end