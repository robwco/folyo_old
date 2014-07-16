class DesignerMailer < ActionMailer::Base

  default from: 'hello@folyo.com'

  layout 'mailer'

  add_template_helper MailerHelper

  def accepted_mail(designer)
    @designer = designer
    subject = "Welcome to Folyo!"
    mail :subject => subject, :from => "Folyo <hello@folyo.me>", :to => designer.email
  end

  def rejected_mail(designer)
    @designer = designer
    subject = "Folyo: sorry, you didn't make it"
    mail :subject => subject, :from => "Folyo <hello@folyo.me>", :to => designer.email
  end

  def rejected_reply(designer, job_offer)
    @designer = designer
    @job_offer = job_offer
    subject = "Folyo: sorry, you didn't get the job"
    mail :subject => subject, :from => "Folyo <hello@folyo.me>", :to => designer.email
  end

end
