require Rails.root.join('lib/mail_interceptor')
ActionMailer::Base.register_interceptor(MailInterceptor) unless Rails.env.production? || Rails.env.staging? || Rails.env.test?
