class ClientMailer < ActionMailer::Base

  default from: 'hello@folyo.com'

  layout 'mailer'

  def new_job_offer(job_offer)
    subject = "[Folyo] #{job_offer.title}"
    @job_offer = job_offer
    mail :subject => subject, :from => "#{job_offer.client.full_name} <#{job_offer.client_email}>", to: Admin.all.map(&:email)
  end

  def job_offer_rejected_mail(job_offer)
    @job_offer = job_offer
    subject = "Sorry, your job offer has been rejected"
    mail :subject => subject, :from => "Folyo <hello@folyo.me>", :to => job_offer.client_email
  end

  def job_offer_replied(designer_reply)
    subject = "#{designer_reply.designer.full_name} has replied to your offer"
    @designer_reply = designer_reply
    message = mail :subject => subject, :from => "#{designer_reply.designer.full_name} <#{designer_reply.designer.email}>", :to => designer_reply.job_offer.client_email
  end

end
