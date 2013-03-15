class JobOffersController < ApplicationController

  load_and_authorize_resource
  inherit_resources

  def create
    create! { offers_path }
  end

  def update
    update! { edit_offer_path(@job_offer)}
  end

  protected

  def collection
    @job_offers = if current_user.is_a? Client
      current_user.job_offers
    else
      JobOffer.all
    end
    @job_offers = @job_offers.page(params[:page]).per(10).ordered
  end

end