class Admin::JobOffersController < Admin::BaseController

  actions :index, :show, :destroy

  section :job_offers

  def destroy
    destroy!{ admin_offers_path }
  end

  def full_list
    @job_offers ||= JobOffer.page(params[:page]).per(10).ordered.paid
  end

  def active
    @job_offers = JobOffer.page(params[:page]).per(10).ordered.paid
  end

  def archived
    @job_offers = JobOffer.page(params[:page]).per(10).ordered.archived
  end

  def rejected
    @job_offers = JobOffer.page(params[:page]).per(10).ordered.rejected
  end

  def refunded
    @job_offers = JobOffer.page(params[:page]).per(10).ordered.refunded
  end

  protected

    def resource
      @job_offer ||= JobOffer.find(params[:id])
    end

    def collection
      @job_offers = JobOffer.page(params[:page]).per(10).ordered_by_status
    end

end