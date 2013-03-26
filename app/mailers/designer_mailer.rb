require 'folyo_mailer'

class DesignerMailer < FolyoMailer

  def accepted_mail(designer)
    folyo_send do
      @designer = designer
      subject = "Welcome to Folyo!"
      mail :subject => subject, :from => "Folyo <hello@folyo.me>", :to => designer.email
    end
  end

  def rejected_mail(designer)
    folyo_send do
      @designer = designer
      subject = "Sorry, you didn't make it"
      mail :subject => subject, :from => "Folyo <hello@folyo.me>", :to => designer.email
    end
  end

  def rejected_reply(designer, job_offer)
    folyo_send do
      @designer = designer
      @job_offer = job_offer
      subject = "[Folyo] Sorry, you didn't get the job"
      mail :subject => subject, :from => "Folyo <hello@folyo.me>", :to => designer.email
    end
  end

end
