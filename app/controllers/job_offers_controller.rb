class JobOffersController < ApplicationController

  load_and_authorize_resource
  inherit_resources

  def create
    create! { offers_path }
  end

  def update
    update! { offer_path(@job_offer)}
  end

  protected

  def begin_of_association_chain
    current_user
  end

  def collection
    @job_offers = end_of_association_chain.page(params[:page]).per(10).ordered
  end

end