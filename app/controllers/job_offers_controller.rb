class JobOffersController < ApplicationController

  inherit_resources
  load_and_authorize_resource except: :show_by_pg_id

  def show_by_pg_id
    @job_offer = JobOffer.where(pg_id: params[:id].to_i).first
    raise Mongoid::Errors::DocumentNotFound.new(JobOffer, pg_id: params[:id].to_i) if @job_offer.nil?
    redirect_to offer_url(@job_offer), status: :moved_permanently
  end

  def index
    @job_offers = collection
    if current_user && current_user.is_a?(Client)
      render 'job_offers/client/index'
    else
      render 'job_offers/designer/index'
    end
  end

  def archives
    @job_offers = JobOffer.page(params[:page]).per(10).archived
    render 'job_offers/designer/archives'
  end

  def history
    @job_offers = JobOffer.for_designer(current_user)
    render 'job_offers/designer/history'
  end

  def create
    @job_offer.client = current_user
    create! { offers_path }
  end

  def update
    update! { edit_offer_path(@job_offer)}
  end

  def show_archive
    @designers_who_replied = @job_offer.designer_replies.map(&:designer)
  end

  def archive
    track_event("Job Offer Archived", {mp_note: @job_offer.title, job_offer_id: @job_offer.id, job_offer_title: @job_offer.title})

    if current_user.is_a? Admin
      @job_offer.archive!(params['designer_users'], false)
    else
      @job_offer.archive!(params['designer_users'])
    end
    redirect_to edit_offer_evaluations_path(@job_offer), notice: "Your job offer has been archived. Once you're done working with the designer, you can come back here to let us know how it went :)"
  end


  protected

  def collection
    @job_offers = if current_user.is_a? Client
      current_user.job_offers
    else
      JobOffer.paid
    end
    @job_offers = @job_offers.page(params[:page]).per(10).ordered
  end

end