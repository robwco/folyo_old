require 'mailchimp'

class MailChimpHelper

  API_KEY = '1ba18f507cfd9c56d21743736aee9a40-us2'
  LIST_ID = 'd2a9f4aa7d'

  def initialize
    @mc = Mailchimp::API.new(API_KEY)
  end

  def list_subscribe(email)
    unless Rails.env.test?
      @mc.lists.subscribe(LIST_ID, { email: email}, {}, 'html', false, true, true, false)
    end
  end

  def list_unsubscribe(email)
    unless Rails.env.test?
      @mc.lists.unsubscribe(LIST_ID, { email: email }, false, false, false)
    end
  end

end
