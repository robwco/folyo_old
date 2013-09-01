class Admin::JobOffersController < Admin::BaseController

  actions :index, :show, :destroy

  section :job_offers

  def update
    update! { edit_offer_path(@job_offer)}
  end

  def accept
    @job_offer.accept
    redirect_to edit_offer_path(@job_offer), notice: 'Offer has been successfully accepted'
  end

  def reject
    if @job_offer.reject(params[:job_offer][:review_comment])
      redirect_to edit_offer_path(@job_offer), notice: 'Offer has been rejected'
    else
      render '/job_offers/edit'
    end
  end

  def newsletter_setup
    @job_offers = JobOffer.page(params[:page]).per(10).ordered.accepted
  end

  def destroy
    destroy!{ admin_offers_path }
  end

  def to_markdown
    if @job_offer.to_markdown!
      redirect_to offer_path(@job_offer), notice: 'Successfully converted to markdown'
    else
      render '/job_offers/edit'
    end
  end

  def full_list
    @job_offers ||= JobOffer.page(params[:page]).per(10).ordered.paid
  end

  def waiting_for_submission
    @job_offers = JobOffer.page(params[:page]).per(10).ordered.waiting_for_submission
  end

  def waiting_for_payment
    @job_offers = JobOffer.page(params[:page]).per(10).ordered.waiting_for_payment
  end

  def waiting_for_review
    @job_offers = JobOffer.page(params[:page]).per(10).ordered.waiting_for_review
  end

  def rejected
    @job_offers = JobOffer.page(params[:page]).per(10).ordered.rejected
  end

  def accepted
    @job_offers = JobOffer.page(params[:page]).per(10).ordered.accepted_or_sent
  end

  def archived
    @job_offers = JobOffer.page(params[:page]).per(10).ordered.archived_or_rated
  end

  def refunded
    @job_offers = JobOffer.page(params[:page]).per(10).ordered.refunded
  end

  protected

    def resource
      @job_offer ||= JobOffer.find(params[:id])
    end

    def collection
      @job_offers = JobOffer.pending.page(params[:page]).per(10).ordered_by_status
    end

end