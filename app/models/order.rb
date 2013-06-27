class Order

  include Mongoid::Document
  include Mongoid::Timestamps

  field :express_token,     type: String
  field :express_payer_id,  type: String
  field :ip_address,        type: String
  field :email,             type: String
  field :details,           type: String
  field :total,             type: Integer
  field :refunded_at,       type: DateTime
  field :error_message,     type: String

  field :pg_id

  ## associations ##
  embedded_in :job_offer

  def purchase(job_offer)
    if process_purchase(job_offer).success?
      job_offer.pay
      track_event
      true
    else
      false
    end
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

  def refund
    response = EXPRESS_GATEWAY.transfer(job_offer.price, self.email, subject: "Folyo refund - #{@job_offer.title}")
    if response.success?
      self.refunded_at = DateTime.now
      save
    else
      self.error_message = response.message
      save
      false
    end
  end

  private

  def process_purchase(job_offer)
    EXPRESS_GATEWAY.purchase(job_offer.price, {
      ip:       ip_address,
      token:    express_token,
      payer_id: express_payer_id
    })
  end

  def track_event
    job_offer.client.track_user_event("Payment", job_offer_title: job_offer.title, job_offer_id: job_offer.id)
  end

end