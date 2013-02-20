class AR::Order < ActiveRecord::Base

  self.table_name = 'orders'

  belongs_to :job_offer

  def purchase(job_offer)
    response = process_purchase(job_offer)
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

  def job_offer
    @job_offer ||= self.job_offer
  end

  private

    def process_purchase(job_offer)

      if job_offer.discount && job_offer.discount=="HN20"
        price=8000
      else
        price=10000
      end
      EXPRESS_GATEWAY.purchase(price, {
        :ip => ip_address,
        :token => express_token,
        :payer_id => express_payer_id
      })
    end

end