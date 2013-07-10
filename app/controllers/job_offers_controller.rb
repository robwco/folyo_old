class JobOffersController < ApplicationController

  inherit_resources
  load_and_authorize_resource except: :show_by_pg_id

  section :job_offers

  def new
    @client = current_user || Client.new
    @job_offer = JobOffer.new_for_client(@client)
  end

  def create
    @client = current_user || Client.new(params[:client])
    @job_offer = JobOffer.new(params[:job_offer])

    # checking if client already exists
    if !current_user && User.for_email(@client.email).count > 0
      flash[:error] = "It seems you already have an account, please <a href='#{new_user_session_path}'>login</a> first"
      render :new and return
    end

    # all job offer fields must be validated if offer is directly submitted
    if params[:workflow_submit]
      @job_offer.force_validation = true
    end

    # in order to get all error messages in form,
    # we want both validations to be executed even if first one is false
    client_valid = @client.valid?
    job_offer_valid = @job_offer.valid?

    # saving client & offer only if both are valid
    if client_valid && job_offer_valid
      @job_offer.client = @client
      @client.save!
      sign_in(@client)
      if params[:workflow_save]
        @job_offer.publish
      elsif params[:workflow_submit]
        @job_offer.submit
      end
      redirect_for_offer(@job_offer)
    else
      render :new
    end
  end

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

  def edit
    @client = @job_offer.client
  end

  def update
    @job_offer.assign_attributes(params[:job_offer])

    # all job offer fields must be validated if offer is directly submitted
    if params[:workflow_submit]
      @job_offer.force_validation = true
    end

    if @job_offer.valid?
      if params[:workflow_save]
        @job_offer.publish
        redirect_to edit_offer_path(@job_offer), notice: 'Your offer has been successfully updated!'
      elsif params[:workflow_submit]
        @job_offer.submit
        redirect_for_offer(@job_offer)
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

  def collection
    @job_offers = if current_user.is_a? Client
      current_user.job_offers
    else
      JobOffer.accepted
    end
    @job_offers = @job_offers.page(params[:page]).per(10).ordered
  end

end