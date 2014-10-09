class MessageMailer < ActionMailer::Base

  default from: 'hello@folyo.me'

  layout 'mailer'

  add_template_helper MailerHelper

  def send_message(message_id)
    @message = Message.find(message_id)
    subject = "Folyo: a message from #{@message.author.full_name}"
    mail subject: subject, reply_to: "#{@message.author.full_name} <#{@message.author.email}>", to: @message.recipient.email
  end

end
