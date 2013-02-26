class MailInterceptor

  def self.delivering_email(mail)
    mail.subject = "#{Rails.env}: Mail to #{mail.to} -  #{mail.subject}"
    mail.to = "folyologs@gmail.com"
    mail.cc = ""
    mail.bcc = ""
  end

end