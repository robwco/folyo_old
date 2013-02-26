class ClientsController < ApplicationController

  inherit_resources
  before_filter :check_user_access
  load_and_authorize_resource

  def index
    redirect_to :root
  end

  def update
     update!{ edit_client_path(resource) }
  end

end
