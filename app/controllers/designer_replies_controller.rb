class DesignerRepliesController < ApplicationController

  inherit_resources

  defaults resource_class: DesignerReply,
           route_collection_name: 'replies',
           route_instance_name: 'reply'

  belongs_to :job_offer, param: 'offer_id'

  authorize_resource

  respond_to :html, :json

  def show
    show! do |format|
      format.html do
        if request.xhr?
          render partial: 'inner_reply', locals: { designer_reply: @designer_reply, with_flash: false }
        else
          fetch_designers
          @designer = @designer_reply.designer

          @previous_replies = @designer_reply.previous(params[:status])
          @previous_reply = @previous_replies.last

          @next_replies = @designer_reply.next(params[:status])
          @next_reply = @next_replies.first

          @reply_count = @previous_replies.length + @next_replies.length + 1
        end
      end
    end
  end

  def index
    index! do
      fetch_designers
    end
  end

  def create
    @designer_reply = parent.designer_replies.build(params[:designer_reply])
    @designer_reply.designer = current_user
    create! do |success, failure|
      success.html { redirect_to offer_path(@job_offer), notice: 'Your reply has been successfully posted, the client has been noticed by email.' }
      failure.html { render template: 'job_offers/show' }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to offer_path(@job_offer), notice: 'Your reply has been successfully updated, the client has been noticed by email.' }
      failure.html { render template: 'job_offers/show' }
    end
  end

  def shortlist
    status_param = params[:status].to_bool rescue nil
    status = resource.toggle_shortlisted!(status_param)
    respond_to do |format|
      format.html { redirect_to offer_reply_url(parent, resource) }
      format.json { render json: { status: status } }
    end
  end

  def hide
    status_param = params[:status].to_bool rescue nil
    status = resource.toggle_hidden!(status_param)
    respond_to do |format|
      format.html { redirect_to offer_reply_url(parent, resource) }
      format.json { render json: { status: status } }
    end
  end

  def mail
    resource
    render 'client_mailer/job_offer_replied', layout: 'mailer'
  end

  protected

  # in order to prevent 1 + N queries, we fetch all designers at once
  def fetch_designers
    Designer.where(:_id.in => collection.map(&:designer_id)).to_a
  end

  def collection
    @designer_replies ||= end_of_association_chain.with_status(params[:status])
  end

end