class OrdersController < ApplicationController

  before_filter :set_job_offer

  load_and_authorize_resource

  section :job_offers

  def new
    redirect_for_offer(@job_offer) unless @job_offer.waiting_for_payment?
  end

  def checkout
    setup_response = EXPRESS_GATEWAY.setup_purchase(@job_offer.price,
      items: [ {
        name:     'Job Offer on Folyo',
        quantity: 1,
        amount:   @job_offer.price
      }],
      locale:            'en_us',
      ip:                request.remote_ip,
      return_url:        confirm_offer_order_url,
      cancel_return_url: new_offer_order_url
    )
    redirect_to EXPRESS_GATEWAY.redirect_url_for(setup_response.token)
  end

  def confirm
    redirect_for_offer(@job_offer) unless params[:token] && @job_offer.waiting_for_payment?
    @order = Order.new(express_token: params[:token])
  end

  def create
    @order = @job_offer.build_order(params[:order])
    @order.ip_address = request.remote_ip
    if @order.save
      if @order.purchase(@job_offer)
        track_event("Payment", { mp_note: @job_offer.title, job_offer_title: @job_offer.title, job_offer_id: @job_offer.id })
        redirect_for_offer(@job_offer)
      else
        render action: 'failure'
      end
    else
      render action: 'failure'
    end
  end

  protected

  def set_job_offer
    @job_offer ||= JobOffer.find(params[:offer_id])
  end

end
