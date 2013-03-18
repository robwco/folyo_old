class OrdersController < ApplicationController

  before_filter :define_job, :only => [:new, :index, :create, :checkout]

  def checkout
    if @job_offer.discount && @job_offer.discount=="HN20"
      price = 8000
    else
      price = 10000
    end
    setup_response = EXPRESS_GATEWAY.setup_purchase(price,
      :items => [
          {
            :name => "Job Offer on Folyo",
            :quantity => 1,
            :amount => price
          }
        ],
      :ip                => request.remote_ip,
      :return_url        => new_offer_order_url,
      :cancel_return_url => url_for(:action => 'index', :only_path => false)
    )
    redirect_to EXPRESS_GATEWAY.redirect_url_for(setup_response.token)
  end

  def new
    @order = Order.new(:express_token => params[:token])
  end

  def create
    @order = @job_offer.build_order(params[:order])
    @order.ip_address = request.remote_ip
    if @order.save
      if @order.purchase(@job_offer)
        @job_offer.status_id = JobOffer::Status_Keys::PAID
        @job_offer.save

        track_event("Payment", {:mp_note => @job_offer.title, :job_offer_title => @job_offer.title, :job_offer_id => @job_offer.id})

        render :action => "index"
      else
        render :action => "failure"
      end
    else
      render :action => 'new'
    end
  end

  protected

    def define_job
      @job_offer ||= JobOffer.find(params[:offer_id])
    end

end
