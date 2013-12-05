class DesignerProjectArtworksController < ApplicationController

  inherit_resources

  defaults resource_class: DesignerProjectArtwork,
           collection_name: 'artworks', route_collection_name: 'artwork',
           instance_name: 'artwork',    route_instance_name: 'artwork'

  belongs_to :designer do
    belongs_to :project, param: 'project_id'
  end

  include Paperclipable::Controller

  protected

  def resource_name
    'artwork'
  end
  helper_method :resource_name

end