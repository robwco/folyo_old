class Order

  include Mongoid::Document
  include Mongoid::Timestamps

  field :express_token,                type: String
  field :express_payer_id,             type: String
  field :transaction_id,               type: String
  field :ip_address,                   type: String
  field :email,                        type: String
  field :details,                      type: String
  field :total,                        type: Float
  field :refunded_at,                  type: DateTime
  field :error_message,                type: String
  field :referral_bonus_transfered_at, type: DateTime

  embedded_in :job_offer

  def setup_purchase(return_url, cancel_return_url, remote_ip)
    setup_response = EXPRESS_GATEWAY.setup_purchase(job_offer.paypal_price,
      items: [ {
        name:     'Job Offer on Folyo',
        quantity: 1,
        amount:   job_offer.paypal_price
      }],
      locale:            'en_us',
      ip:                remote_ip,
      return_url:        return_url,
      cancel_return_url: cancel_return_url
    )
    EXPRESS_GATEWAY.redirect_url_for(setup_response.token)
  end

  def purchase(job_offer)
    if process_purchase(job_offer).success?
      job_offer.pay
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
    if self.transaction_id.nil?
      self.update_attribute(:error_message , 'No transaction id saved for this order. Please do a manual refund')
      return false
    end

    response = EXPRESS_GATEWAY.refund(nil, self.transaction_id)
    if response.success?
      self.update_attribute(:refunded_at, DateTime.now)
    else
      self.update_attribute(:error_message, response.message)
      false
    end
  end

  def referral_bonus_available_at
    if job_offer.published?
      job_offer.approved_at + 60.days
    else
      nil
    end
  end

  def referral_bonus_available?
    referral_bonus_available_at <= DateTime.now
  end

  def referral_bonus
    (self.total || job_offer.discounted_price).to_f * JobOffer::REFERRAL_BONUS / 100
  end

  def mark_bonus_as_transfered!
    self.update_attribute(:referral_bonus_transfered_at, DateTime.now)
  end

  private

  def process_purchase(job_offer)
    response = EXPRESS_GATEWAY.purchase(job_offer.paypal_price, {
      ip:       ip_address,
      token:    express_token,
      payer_id: express_payer_id
    })
    self.update_attribute(:transaction_id, response.params['transaction_id'])
    response
  end

end