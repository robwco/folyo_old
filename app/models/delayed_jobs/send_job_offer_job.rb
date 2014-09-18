module DelayedJobs

  class SendJobOfferJob < Jobbr::DelayedJob

    def perform(params, run)

      if job_offer = JobOffer.find(params[:job_offer_id])

        designers = Designer.accepted.subscribed_for(job_offer.skills)
        Rails.logger.debug "Sending #{job_offer.title} to #{designers.count} designers"

        designers.each_slice(200) do |designers|
          designer_emails = designers.map(&:email)
          Rails.logger.debug "Sending to #{designer_emails}"
          JobOfferMailer.new_job_offer(job_offer, designer_emails).deliver
        end
      end

    end

  end

end
