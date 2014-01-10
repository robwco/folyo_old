class JobOffersController < ApplicationController

  inherit_resources
  load_and_authorize_resource except: :show_by_pg_id

  section :job_offers

  def show
    if current_user && current_user.is_a?(Designer)
      unless @designer_reply = @job_offer.reply_by(current_user)
        @designer_reply = @job_offer.designer_replies.build
      end
    end
    show!
  end

  def new
    @job_offer = JobOffer.new_for_client(current_user)
    @job_offer.skip_validation = true
    @job_offer.publish
    redirect_for_offer(@job_offer, signup: params[:signup])
  end

  def show_by_pg_id
    @job_offer = JobOffer.where(pg_id: params[:id].to_i).first
    raise Mongoid::Errors::DocumentNotFound.new(JobOffer, pg_id: params[:id].to_i) if @job_offer.nil?
    redirect_to offer_url(@job_offer), status: :moved_permanently
  end

  def index
    session[:job_offer_index_path] = request.fullpath
    @job_offers = collection
    fetch_clients_for(@job_offers)
    if current_user && current_user.is_a?(Client)
      render 'job_offers/client/index'
    else
      render 'job_offers/designer/index'
    end
  end

  def archives
    session[:job_offer_index_path] = request.fullpath
    @job_offers = JobOffer.page(params[:page]).per(10).archived
    fetch_clients_for(@job_offers)
    render 'job_offers/designer/archives'
  end

  def history
    session[:job_offer_index_path] = request.fullpath
    @job_offers = JobOffer.for_designer(current_user)
    fetch_clients_for(@job_offers)
    render 'job_offers/designer/history'
  end

  def edit
    @client = @job_offer.client
  end

  def update
    @job_offer.assign_attributes(params[:job_offer])

    # all job offer fields must be validated if offer is directly submitted
    if params[:workflow_save]
      @job_offer.skip_validation = true
    end

    if @job_offer.valid?
      if params[:workflow_submit] && @job_offer.can_submit?
        @job_offer.submit
        redirect_for_offer(@job_offer, signup: params[:signup])
      else
        @job_offer.publish
        redirect_to edit_offer_path(@job_offer, signup: params[:signup]), notice: 'Your offer has been successfully updated!'
      end
    else
      render :edit
    end
  end

  def show_archive
    @designers_who_replied = @job_offer.designer_replies.map(&:designer)
  end

  def archive
    if current_user.is_a?(Admin)
      @job_offer.archive(params['designer_users'], false)
    else
      @job_offer.archive(params['designer_users'])
    end
    redirect_to edit_offer_evaluations_path(@job_offer), notice: "Your job offer has been archived. Once you're done working with the designer, you can come back here to let us know how it went :)"
  end

  protected

  # in order to prevent 1 + N queries, we fetch all clients at once
  def fetch_clients_for(job_offers)
    Client.where(:_id.in => job_offers.map(&:client_id)).to_a
  end

  def collection
    @job_offers = if current_user.is_a? Client
      current_user.job_offers
    else
      JobOffer.accepted
    end
    @job_offers = @job_offers.page(params[:page]).per(10).ordered
  end

end