class Order

  include Mongoid::Document
  include Mongoid::Timestamps

  field :express_token,     type: String
  field :express_payer_id,  type: String
  field :ip_address,        type: String
  field :email,             type: String
  field :details,           type: String
  field :total,             type: Integer

  field :pg_id

  ## associations ##
  embedded_in :job_offer

  def purchase(job_offer)
    response = process_purchase(job_offer)
    track_event
    #transactions.create!(:action => "purchase", :amount => price_in_cents, :response => response)
    #cart.update_attribute(:purchased_at, Time.now) if response.success?
    response.success?
  end

  def express_token=(token)
    write_attribute(:express_token, token)
    if new_record? && !token.blank?
      details = EXPRESS_GATEWAY.details_for(token)
      self.express_payer_id = details.payer_id
      self.email = details.params["PayerInfo"]["Payer"]
      self.total = details.params["order_total"]
      self.details = details
    end
  end

  private

  def process_purchase(job_offer)
    if job_offer.discount && job_offer.discount == "HN20"
      price = 8000
    else
      price = 10000
    end

    EXPRESS_GATEWAY.purchase(price, {
      ip: ip_address,
      token: express_token,
      payer_id: express_payer_id
    })
  end

  def track_event
    job_offer.client.track_user_action("Payment", job_offer_title: job_offer.title, job_offer_id: job_offer.id)
  end

end