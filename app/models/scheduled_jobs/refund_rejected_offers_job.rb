module ScheduledJobs

  class RefundRejectedOffersJob < Jobbr::ScheduledJob

    description 'Automatically refund offers rejected more than 10 days ago'

    heroku_run :daily, priority: 0

    def perform
      JobOffer.rejected.each do |offer|
        offer.refund_if_needed!(10.days)
      end
    end

  end

end