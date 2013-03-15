class DesignerRepliesController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  def index
    track_event("Viewing Designer Replies", {:mp_note => @job_offer.title, :job_offer_id => @job_offer.id, :job_offer_title => @job_offer.title})
    @designer_replies = self.collection.ordered
    index!
  end

  def create
    @designer_reply = begin_of_association_chain.designer_replies.build(params[:designer_reply])
    @designer_reply.designer = current_user
    @designer_reply.save
    track_event("New designer reply", {:mp_note => "Replying to '#{@designer_reply.job_offer.title}", designer_id: current_user.id, job_offer_title: @designer_reply.job_offer.title, job_offer_id:  @designer_reply.job_offer.id})

    create! do |success, failure|
      success.html { redirect_to :back }
    end
  end

  def pick
     respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def update_pick
    track_event("Job Offer Archived", {:mp_note => @job_offer.title, :job_offer_id => @job_offer.id, :job_offer_title => @job_offer.title})
    @job_offer.archive!(@designer_reply.user_id)
    redirect_to edit_client_offer_evaluations_path(@job_offer), :notice => "Excellent, you just picked a designer! Once you're done working with them, you can come back here to let us know how it went :)"
  end

  respond_to :html, :json

  def update
    # don't know why, but "update!" was throwing an error, so replaced it by "super"
    super do |format|
      format.json do
        if params[:collapsed]
          @designer_reply.collapsed = params[:collapsed]
        end
        @designer_reply.save
        render :json => @designer_reply
      end
    end
  end

  protected

  def begin_of_association_chain
    @job_offer ||= JobOffer.find(params[:offer_id])
  end

end