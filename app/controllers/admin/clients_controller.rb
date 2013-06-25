class Admin::ClientsController < Admin::BaseController

  actions :index, :show

  section :clients

  def to_markdown
    @client.to_markdown!
    redirect_to client_path(@client), notice: 'Successfully converted to markdown'
  end

  protected

    def collection
      @clients = Client.page(params[:page]).per(10).ordered
    end
end