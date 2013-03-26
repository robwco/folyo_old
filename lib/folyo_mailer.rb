class FolyoMailer < ActionMailer::Base

  default from: 'hello@folyo.com'
  default bcc: Admin.all.map(&:email)

  def folyo_send(&block)
    message = yield
    message.body = Premailer.new(message.body.to_s, with_html_string: true).to_inline_css
    message
  end

end