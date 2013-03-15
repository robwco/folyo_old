class Admin::ClientsController < Admin::BaseController

  actions :index, :show

  protected

    def collection
      @clients = Client.page(params[:page]).per(10).ordered
    end
end