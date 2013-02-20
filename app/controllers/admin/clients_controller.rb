class Admin::ClientsController < Admin::BaseController

  actions :index, :show

  protected
  
    def collection
      @clients = Client.paginate(:page => params[:page], :per_page => 10).ordered
    end
end