class ContactMailer < ActionMailer::Base
  default :from => 'hello@folyo.me'

  def contact_form(user, designer, message)
    subject = "[Folyo] A message from #{user.full_name} (#{user.client.company_name})"

    mail :subject => subject, :from => user.email, :to => designer.useremail
  end
end
