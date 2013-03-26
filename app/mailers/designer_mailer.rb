class DesignerMailer < ActionMailer::Base

  default from: 'hello@folyo.com'
  default bcc:  Admin.all.map(&:email)

  layout 'mailer'

  def accepted_mail(designer)
    @designer = designer
    subject = "Welcome to Folyo!"
    mail :subject => subject, :from => "Folyo <hello@folyo.me>", :to => designer.email
  end

  def rejected_mail(designer)
    @designer = designer
    subject = "Sorry, you didn't make it"
    mail :subject => subject, :from => "Folyo <hello@folyo.me>", :to => designer.email
  end

  def rejected_reply(designer, job_offer)
    @designer = designer
    @job_offer = job_offer
    subject = "[Folyo] Sorry, you didn't get the job"
    mail :subject => subject, :from => "Folyo <hello@folyo.me>", :to => designer.email
  end

end
