class MailChimpHelper

  API_KEY = '1ba18f507cfd9c56d21743736aee9a40-us2'
  LIST_ID = 'd2a9f4aa7d'
  TEMPLATE_ID = '261141'

  def initialize
    @mc = Mailchimp::API.new(API_KEY)
  end

  def campaign_create(subject, content)
    @mc.campaigns.create('regular', {
      template_id: TEMPLATE_ID,
      from_email: 'hello@folyo.me',
      from_name:  'Folyo',
      list_id: LIST_ID,
      subject: subject },
      {sections: {body: content }})
  end

  def campaign_send_test(campaign, email = 'folyologs@gmail.com')
    @mc.campaigns.send_test(campaign['id'], email)
  end

  def campaign_send(campaign)
    if Rails.env.production?
      @mc.campaigns.send(campaign['id'])
    else
      campaign_send_test(campaign)
    end
  end

  def list_subscribe(email)
    @mc.list.subscribe(LIST_ID, {email: {email: email}}, {}, 'html', false, true, true, false)
  end

  def list_unsubscribe(email)
    @mc.list.unsubscribe(LIST_ID, {email: {email: email}}, false, false, false)
  end

end