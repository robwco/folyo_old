require 'mailchimp'

class MailChimpHelper

  API_KEY = '1ba18f507cfd9c56d21743736aee9a40-us2'
  LIST_ID = 'd2a9f4aa7d'
  TEMPLATE_ID = '261141'

  def initialize
    @mc = Mailchimp::API.new(API_KEY)
  end

  def campaign_create(subject, content)
    campaign = @mc.campaigns.create('regular', {
      template_id: TEMPLATE_ID,
      from_email: 'hello@folyo.me',
      from_name:  'Folyo',
      list_id: LIST_ID,
      title: subject,
      subject: subject },
      { sections: { body: content } })
    campaign['id']
  end

  def campaign_update(cid, subject, content)
    @mc.campaigns.update(cid, 'options', { title: subject, subject: subject})
    @mc.campaigns.update(cid, 'content', { sections: { body: content } })
  end

  def campaign_delete(cid)
    @mc.campaigns.delete(cid)
  end

  def campaign_send(cid)
    if Rails.env.production?
      @mc.campaigns.send(cid)
    else
      campaign_send_test(cid)
    end
  end

  def campaign_send_test(cid, email = 'folyologs@gmail.com')
    @mc.campaigns.send_test(cid, [email])
  end

  def list_subscribe(email)
    @mc.lists.subscribe(LIST_ID, { email: email}, {}, 'html', false, true, true, false)
  end

  def list_unsubscribe(email)
    @mc.lists.unsubscribe(LIST_ID, { email: email }, false, false, false)
  end

end