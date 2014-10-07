class ClientsController < ApplicationController

  inherit_resources
  before_filter :check_user_access
  load_and_authorize_resource

  section :clients

  def index
    redirect_to :root
  end

  def update
     update!{ edit_client_path(resource) }
  end

  def permitted_params
    params.permit(client: [:company_name, :company_url, :company_description, :location])
  end

end
