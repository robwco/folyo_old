class JobOfferMailer < ActionMailer::Base

  default from: 'Folyo <hello@folyo.com>'

  layout 'mailer'

  add_template_helper MailerHelper
  add_template_helper ApplicationHelper

  def new_job_offer_to_moderate(job_offer)
    subject = "[Folyo] [New job offer] #{job_offer.title}"
    @job_offer = job_offer
    mail subject: subject, reply_to: "#{job_offer.client.full_name} <#{job_offer.client_email}>", to: Admin.all.map(&:email) do |format|
      format.html { render 'new_job_offer' }
    end
  end

  def updated_job_offer(job_offer)
    subject = "[Folyo] [Updated job offer] #{job_offer.title}"
    @job_offer = job_offer
    mail subject: subject, reply_to: "#{job_offer.client.full_name} <#{job_offer.client_email}>", to: Admin.all.map(&:email) do |format|
      format.html { render 'new_job_offer' }
    end
  end

  def new_job_offer(job_offer, designer_emails)
    @job_offer = job_offer
    subject = "[Folyo] [New job offer] #{job_offer.title}"
    mail subject: subject, to: designer_emails
  end

end
