require 'folyo_mailer'

class MessageMailer < FolyoMailer

   def send_message(message)
    folyo_send do
      @message = message
      subject = "[Folyo] A message from #{message.from_user.full_name}"
      mail subject: subject, from: "#{message.from_user.full_name} <#{message.from_user.email}>", to: message.to_user.email
    end
  end

end
