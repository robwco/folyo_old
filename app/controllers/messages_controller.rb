class MessagesController < ApplicationController

  inherit_resources

  section :designers

  before_filter :set_to_user, :set_job_offer
  before_filter :get_referer, only: :new

  layout false

  def create
    @message = Message.new(:comment => params[:message][:comment])
    @message.to_user = @to_user
    @message.from_user = current_user
    @message.job_offer = @job_offer
    @message.save

    create! do |success, failure|
      notice = 'Message was successfully sent'
      if session[:return_to]
        success.html { redirect_to session[:return_to], notice: notice }
      else
        success.html { redirect_to :back, notice: notice }
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

  def set_job_offer
    @job_offer = JobOffer.find(params[:job_offer_id])
  end

  def get_referer
    session[:return_to]= request.referer
  end

end