class DesignerRepliesController < ApplicationController

  inherit_resources

  defaults resource_class: DesignerReply,
           route_collection_name: 'replies',
           route_instance_name: 'reply'

  belongs_to :job_offer, param: 'offer_id'

  load_and_authorize_resource

  respond_to :html, :json

  def index
    index! do
      # in order to prevent 1 + N queries, we fetch all designers at once
      @designers = Designer.where(:_id.in => @designer_replies.map(&:designer_id)).inject({}) do |hash, designer|
        hash.tap do |hash|
          hash[designer.id] = designer
        end
      end
    end

  end

  def create
    @designer_reply = @job_offer.designer_replies.build(params[:designer_reply])
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

  def pick
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def update_pick
    @job_offer.archive(@designer_reply.designer_id)
    redirect_to edit_offer_evaluations_path(@job_offer), notice: "Excellent, you just picked a designer! Once you're done working with them, you can come back here to let us know how it went :)"
  end

  protected

  def collection
    @designer_replies ||= end_of_association_chain.ordered
  end

end