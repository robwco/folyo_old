class ClientMailer < ActionMailer::Base

  default from: 'hello@folyo.com'

  layout 'mailer'

  add_template_helper MailerHelper

  def new_job_offer(job_offer)
    subject = "[Folyo] [New offer] #{job_offer.title}"
    @job_offer = job_offer
    mail subject: subject, reply_to: "#{job_offer.client.full_name} <#{job_offer.client_email}>", to: Admin.all.map(&:email)
  end

  def updated_job_offer(job_offer)
    subject = "[Folyo] [Updated offer] #{job_offer.title}"
    @job_offer = job_offer
    mail subject: subject, reply_to: "#{job_offer.client.full_name} <#{job_offer.client_email}>", to: Admin.all.map(&:email)
  end

  def job_offer_replied(designer_reply)
    subject = "Folyo: #{designer_reply.designer.full_name} has replied to your offer"
    @designer_reply = designer_reply
    message = mail subject: subject, reply_to: "#{designer_reply.designer.full_name} <#{designer_reply.designer.email}>", to: designer_reply.job_offer.client_email
  end

end
