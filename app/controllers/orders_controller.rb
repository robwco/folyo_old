class OrdersController < ApplicationController

  before_filter :set_job_offer

  load_and_authorize_resource

  section :job_offers

  def new
    redirect_for_offer(@job_offer) unless @job_offer.waiting_for_payment?
  end

  def checkout
    order = @job_offer.build_order
    {}.tap do |options|
      options[:signup] = params[:signup] unless params[:signup].blank?
      checkout_url = order.setup_purchase(confirm_offer_order_url(options), new_offer_order_url(options), request.remote_ip)
      redirect_to checkout_url
    end
  end

  def confirm
    redirect_for_offer(@job_offer) unless params[:token] && @job_offer.waiting_for_payment?
    @order = Order.new(express_token: params[:token])
  end

  def create
    @order = @job_offer.build_order(order_params)
    @order.ip_address = request.remote_ip
    if @order.save
      if @order.purchase(@job_offer)
        track_event("Payment", { job_offer_title: @job_offer.title, job_offer_id: @job_offer.id })
        redirect_for_offer(@job_offer)
      else
        render action: 'failure'
      end
    else
      render action: 'failure'
    end
  end

  protected

  def order_params
    params[:order].permit!
  end

  def set_job_offer
    @job_offer ||= JobOffer.find(params[:offer_id])
  end

end
