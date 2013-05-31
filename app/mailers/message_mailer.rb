class MessageMailer < ActionMailer::Base

  default from: 'hello@folyo.com'

  layout 'mailer'

  def send_message(message)
    @message = message
    subject = "Folyo: a message from #{message.from_user.full_name}"
    mail subject: subject, from: "#{message.from_user.full_name} <#{message.from_user.email}>", to: message.to_user.email
  end

end
