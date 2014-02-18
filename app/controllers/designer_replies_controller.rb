class DesignerRepliesController < ApplicationController

  inherit_resources

  defaults resource_class: DesignerReply,
           route_collection_name: 'replies',
           route_instance_name: 'reply'

  belongs_to :job_offer, param: 'offer_id'

  load_and_authorize_resource

  respond_to :html, :json

  def show
    show! do |format|
      format.html {
        fetch_designers
        @designer = @designer_reply.designer

        @previous_replies = @designer_reply.previous
        @previous_reply = @previous_replies.last

        @next_replies = @designer_reply.next
        @next_reply = @next_replies.first

        @reply_count = @previous_replies.length + @next_replies.length + 1
      }
      format.js {
        render partial: 'inner_reply', locals: { designer_reply: @designer_reply }
      }

    end
  end

  def index
    index! do
      fetch_designers
    end
  end

  def create
    @designer_reply.designer = current_user
    create! do |success, failure|
      success.html { redirect_to offer_path(@job_offer), notice: 'Your offer has been successfully created, the client has been noticed by email.' }
      failure.html { render template: 'job_offers/show' }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to offer_path(@job_offer), notice: 'Your offer has been successfully updated, the client has been noticed by email.' }
      failure.html { render template: 'job_offers/show' }
    end
  end

  def shortlist
    render json: { status: @designer_reply.toggle_shortlisted! }
  end

  def hide
    render json: { status: @designer_reply.toggle_hidden! }
  end

  protected

  # in order to prevent 1 + N queries, we fetch all designers at once
  def fetch_designers
    Designer.where(:_id.in => @job_offer.designer_replies.map(&:designer_id)).to_a
  end

  def collection
    status = params[:status] || 'default'
    @designer_replies ||= end_of_association_chain
    unless status == 'all'
      @designer_replies = @designer_replies.where(status: status.to_sym)
    end
  end

end