class JobOfferMailer < ActionMailer::Base

  default from: 'hello@folyo.com'

  layout 'mailer'

  add_template_helper MailerHelper

  def new_job_offer_to_moderate(job_offer)
    subject = "[Folyo] [New job offer] #{job_offer.title}"
    @job_offer = job_offer
    mail subject: subject, reply_to: "#{job_offer.client.full_name} <#{job_offer.client_email}>", to: Admin.all.map(&:email)
  end

  def updated_job_offer(job_offer)
    subject = "[Folyo] [Updated job offer] #{job_offer.title}"
    @job_offer = job_offer
    mail subject: subject, reply_to: "#{job_offer.client.full_name} <#{job_offer.client_email}>", to: Admin.all.map(&:email)
  end

  def new_job_offer(job_offer, designer)
    @designer = designer
    subject = "[Folyo] [New job offer] #{job_offer.title}"
    mail subject: subject, from: "Folyo <hello@folyo.me>", to: designer.email
  end

end
