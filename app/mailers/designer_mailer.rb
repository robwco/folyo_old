class DesignerMailer < ActionMailer::Base

  default from: 'hello@folyo.me'

  layout 'mailer'

  add_template_helper MailerHelper

  def accepted_mail(designer_id)
    @designer = Designer.find(designer_id)
    subject = "Welcome to Folyo!"
    mail subject: subject, from: "Folyo <hello@folyo.me>", to: @designer.email
  end

  def rejected_mail(designer_id)
    @designer = Designer.find(designer_id)
    subject = "[Folyo] Sorry, you didn't make it"
    mail subject: subject, from: "Folyo <hello@folyo.me>", to: @designer.email
  end

  def rejected_reply(designer_id, job_offer_id)
    @designer = Designer.find(designer_id)
    @job_offer = JobOffer.find(job_offer_id)
    subject = "[Folyo] Sorry, you didn't get the job"
    mail subject: subject, from: "Folyo <hello@folyo.me>", to: @designer.email
  end

end
