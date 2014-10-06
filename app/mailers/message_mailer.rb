class MessageMailer < ActionMailer::Base

  default from: 'hello@folyo.me'

  layout 'mailer'

  add_template_helper MailerHelper

  def send_message(message_id)
    @message = Message.find(message_id)
    subject = "Folyo: a message from #{@message.from_user.full_name}"
    mail subject: subject, reply_to: "#{@message.from_user.full_name} <#{@message.from_user.email}>", to: @message.to_user.email
  end

end
