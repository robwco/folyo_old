module ScheduledJobs

  class ProcessOffersWorkflowJob < Jobbr::Job

    include Jobbr::Scheduled

    description 'Automatically make job offers progress through workflow'

    heroku_run :daily, priority: 0

    def perform(run)

      # kills offers waiting for submission or payment since more than 1 month
      JobOffer.where(:status.in => [:waiting_for_submission, :waiting_for_payment]).each do |offer|
        offer.kill_if_needed!(1.month)
      end

      # kills offers waiting for submission or payment since more than 1 month
      JobOffer.accepted.each do |offer|
        offer.archive_if_needed!(1.month)
      end

      # refund offers rejected more than 10 days ago
      JobOffer.rejected.each do |offer|
        offer.refund_if_needed!(10.days)
      end
    end

  end

end
