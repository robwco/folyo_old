require 'mailchimp_helper'

class Newsletter

  FIRST_INDEX = 95

  include Mongoid::Document
  include Mongoid::Timestamps

  field :subject,          type: String
  field :sent_at,          type: DateTime
  field :newsletter_index, type: Integer
  field :mailchimp_cid,    type: String

  has_and_belongs_to_many :job_offers

  after_initialize  :set_offers, :set_index, :set_subject, unless: :persisted?
  after_create      :create_mailchimp_newsletter
  after_update      :update_mailchimp_newsletter, if: Proc.new {|n| n.subject_changed? || n.job_offer_ids_changed? }
  before_destroy    :destroy_mailchimp_newsletter

  def fire!
    MailChimpHelper.new.campaign_send(self.mailchimp_cid)
    self.job_offers.each(&:mark_as_sent)
    self.sent_at = DateTime.now
    save!
  end
  handle_asynchronously :send_newsletter

  def send_test(email = nil)
    MailChimpHelper.new.campaign_send_test(self.mailchimp_cid, email)
  end
  handle_asynchronously :send_newsletter_test

  def sent?
    !self.sent_at.nil?
  end

  protected

  def set_offers
    self.job_offer_ids = JobOffer.accepted.order_by(approved_at: :desc).pluck('_id')
  end

  def set_index
    self.newsletter_index = Newsletter.order_by(newsletter_index: :desc).limit(1).first.newsletter_index + 1 rescue FIRST_INDEX
  end

  def set_subject
    company_names = self.job_offers.pluck(:company_name).join(', ')
    self.subject = "Folyo ##{self.newsletter_index}: #{company_names}"
  end

  def create_mailchimp_newsletter
    self.mailchimp_cid = MailChimpHelper.new.campaign_create(self.subject, content)
    save!
  end
  handle_asynchronously :create_mailchimp_newsletter

  def update_mailchimp_newsletter
    MailChimpHelper.new.campaign_update(self.mailchimp_cid, self.subject, content)
  end
  handle_asynchronously :update_mailchimp_newsletter

  def destroy_mailchimp_newsletter
    MailChimpHelper.new.campaign_delete(self.mailchimp_cid)
  end
  handle_asynchronously :destroy_mailchimp_newsletter

  def content
    self.job_offers.map do |offer|
      render_partial '/admin/job_offers/newsletter_offer', {job_offer: offer}
    end.join('<br/><hr/>')
  end

  def render_partial(partial, assigns)
    view = ActionView::Base.new(Rails::Application::Configuration.new.paths['app/views'])
    view.extend ApplicationHelper
    class << view
      include Rails.application.routes.url_helpers
    end
    view.render(partial: partial, locals: assigns)
  end

end