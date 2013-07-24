class Admin::OrdersController < Admin::BaseController

  section :job_offers

  def refund
    @job_offer = JobOffer.find(params[:offer_id])
    if @job_offer.refund
      redirect_to offer_order_path(@job_offer), notice: 'Order successfully refunded'
    else
      redirect_to offer_order_path(@job_offer), alert: "Could not refund the order. #{@job_offer.order.try(:error_message)}"
    end
  end

end