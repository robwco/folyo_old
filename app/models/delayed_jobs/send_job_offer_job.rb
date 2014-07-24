module DelayedJobs

  class SendJobOfferJob < Jobbr::DelayedJob

    def perform(params, run)

      if job_offer = JobOffer.find(params[:job_offer_id])

        designers = Designer.accepted.subscribed_for(job_offer.skills)
        count = designers.count
        Rails.logger.debug "Sending #{job_offer.title} to #{count} designers"

        designers.each_with_index do |designer, index|
          Rails.logger.debug "Sending to #{designer.full_name} <#{designer.email}> - #{index} / #{count}"
          JobOfferMailer.new_job_offer(job_offer, designer).deliver
        end
      end

    end

  end

end
