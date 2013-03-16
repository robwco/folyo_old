class MessagesController < ApplicationController

  inherit_resources

  before_filter :set_to_user
  before_filter :get_referer, only: :new

  def create
    @message = Message.new(:comment => params[:message][:comment])
    @message.to_user = @to_user
    @message.from_user = current_user
    @message.save
#    current_user.track_user_action("New message", {:from_user_id => current_user.id, :from_user_name => current_user.full_name, :to_user_id => @to_user.id, :to_user_name => @to_user.full_name})
    create! do |success, failure|
      if session[:return_to]
        success.html { redirect_to session[:return_to] }
      else
        success.html { redirect_to :back }
      end
    end
  end

  protected

  def set_to_user
    if params[:designer_id]
        @to_user = Designer.find(params[:designer_id])
    elsif params[:client_id]
        @to_user = Client.find(params[:client_id])
    end
  end

  def get_referer
    session[:return_to]= request.referer
  end

end