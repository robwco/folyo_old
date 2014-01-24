require 'mailchimp_helper'

class Newsletter

  FIRST_INDEX = 95

  include Mongoid::Document
  include Mongoid::Timestamps

  field :subject,           type: String
  field :intro,             type: String
  field :sent_at,           type: DateTime
  field :newsletter_index,  type: Integer
  field :mailchimp_cid,     type: String
  field :mailchimp_web_id,  type: String
  field :schedule_date,     type: DateTime
  field :timewarp,          type: Boolean, default: true

  has_and_belongs_to_many :job_offers

  after_initialize  :set_offers, :set_index, :set_subject,                unless: :persisted?
  after_create      :mark_offers_as_sending, :create_mailchimp_newsletter
  after_update      :update_mailchimp_newsletter,                         if: Proc.new { |n| n.subject_changed? || n.job_offer_ids_changed? || n.intro_changed? || n.timewarp_changed? }
  before_destroy    :check_can_be_destroyed, :destroy_mailchimp_newsletter
  after_destroy     :cancel_offers_sending

  def fire!
    if can_send?
      MailChimpHelper.new.campaign_send(self.mailchimp_cid)
      self.job_offers.each(&:mark_as_sent)
      self.sent_at = DateTime.now
      save!
    else
      false
    end
  end

  def send_test(email = nil)
    MailChimpHelper.new.campaign_send_test(self.mailchimp_cid, email)
  end
  handle_asynchronously :send_test

  def schedule!
    if can_schedule? && schedule_date
      MailChimpHelper.new.campaign_schedule(self.mailchimp_cid, schedule_date)
      #self.job_offers.each(&:mark_as_sent) # replace by webhooks
      self.sent_at = schedule_date
      save!
    else
      false
    end
  end

  def sent?
    !self.sent_at.nil? && self.sent_at <= DateTime.now
  end

  def scheduled?
    !self.sent_at.nil? && self.sent_at > DateTime.now
  end

  def can_send?
    !sent?
  end

  def can_schedule?
    !sent? || sent_at > 1.day.from_now
  end

  def preview_url
    if self.mailchimp_web_id
      "https://us2.admin.mailchimp.com/campaigns/preview?id=#{self.mailchimp_web_id}"
    else
      nil
    end
  end

  def self.can_create?
    JobOffer.accepted.count > 0
  end

  def formated_index
    "Folyo ##{self.newsletter_index}"
  end

  def company_names
    self.job_offers.pluck(:company_name).join(', ')
  end

  protected

  def set_offers
    self.job_offer_ids = JobOffer.accepted.order_by(approved_at: :desc).pluck('_id')
  end

  def set_index
    self.newsletter_index = Newsletter.order_by(newsletter_index: :desc).limit(1).first.newsletter_index + 1 rescue FIRST_INDEX
  end

  def set_subject
    self.subject = "#{formated_index}: #{company_names}"
  end

  def mark_offers_as_sending
    self.job_offers.each(&:prepare_for_sending)
  end

  def cancel_offers_sending
    self.job_offers.each(&:cancel_sending)
  end

  def create_mailchimp_newsletter
    campaign = MailChimpHelper.new.campaign_create(self.subject, content, timewarp)
    self.mailchimp_cid = campaign['id']
    self.mailchimp_web_id = campaign['web_id']
    save!
  end
  handle_asynchronously :create_mailchimp_newsletter

  def update_mailchimp_newsletter
    MailChimpHelper.new.campaign_update(self.mailchimp_cid, self.subject, content, timewarp)
  end
  handle_asynchronously :update_mailchimp_newsletter

  def destroy_mailchimp_newsletter
    if self.mailchimp_cid
      MailChimpHelper.new.campaign_delete(self.mailchimp_cid)
    end
  end

  def content
    content = []
    unless self.intro.blank?
      content.append(render_partial('/admin/newsletters/intro', {newsletter: self}))
    end
    self.job_offers.each do |offer|
      content.append(render_partial('/admin/newsletters/job_offer', {job_offer: offer}))
    end
    content.join('<br/><hr/>')
  end

  def render_partial(partial, assigns)
    view = ActionView::Base.new(Rails::Application::Configuration.new.paths['app/views'])
    view.extend ApplicationHelper
    class << view
      include Rails.application.routes.url_helpers
    end
    view.render(partial: partial, locals: assigns)
  end

  def check_can_be_destroyed
    !sent? || sent_at > 1.day.from_now
  end

end