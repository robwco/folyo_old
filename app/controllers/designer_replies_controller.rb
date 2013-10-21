class DesignerRepliesController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  def index
    @designer_replies = self.collection.ordered
    index!
  end

  def create
    @designer_reply = begin_of_association_chain.designer_replies.build(params[:designer_reply])
    @designer_reply.designer = current_user
    @designer_reply.save
    create! { offer_path(@job_offer) }
  end

  def pick
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def update_pick
    @job_offer.archive(@designer_reply.designer_id)
    redirect_to edit_offer_evaluations_path(@job_offer), notice: "Excellent, you just picked a designer! Once you're done working with them, you can come back here to let us know how it went :)"
  end

  respond_to :html, :json

  def update
    super do |format|
      format.json do
        if params[:collapsed]
          @designer_reply.collapsed = params[:collapsed]
        end
        @designer_reply.save
        render :json => @designer_reply
      end
      format.html do
        redirect_to offer_path(@job_offer)
      end
    end
  end

  protected

  def begin_of_association_chain
    @job_offer ||= JobOffer.find(params[:offer_id])
  end

end