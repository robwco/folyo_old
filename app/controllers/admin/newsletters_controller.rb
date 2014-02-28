require 'chronic'

class Admin::NewslettersController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  section :job_offers

  def new
    if Newsletter.can_create?
      @newsletter = Newsletter.create
      redirect_to edit_admin_newsletter_path(@newsletter)
    else
      redirect_to admin_newsletters_path
    end
  end

  def update
    params[:newsletter][:schedule_date] = parse_time(params[:newsletter][:schedule_date])
    update! { edit_admin_newsletter_path(@newsletter) }
    if params['send-test']
      @newsletter.send_test(current_user.email)
      flash[:notice] = "Newsletter has been updated and sent to #{current_user.email}"
    elsif params['fire']
      @newsletter.fire!
      flash[:notice] = "Newsletter has been updated and sent to designers!"
    elsif params['schedule']
      @newsletter.schedule!
      flash[:notice] = "Newsletter has been updated and scheduled for sending"
    end
  end

  def show
    redirect_to edit_admin_newsletter_path(@newsletter)
  end

  # called by mailchimp after a newsletter has been sent
  def webhook
    logger.debug("mailchimp webhook called: #{params.inspect}")
    if params['type'] == 'campaign' && params['data'] && params['data']['status'] == 'sent'
      if newsletter = Newsletter.where(mailchimp_cid: params['data']['id']).first
        logger.debug "marking newsletter #{newsletter.id} as sent"
        newsletter.mark_as_sent!
      end
    end
    render text: 'ok'
  end

  def offer
    JobOffer.find(params[:job_offer_id]).cancel_sending
    @newsletter.job_offers.where(_id: params[:job_offer_id]).delete
    redirect_to admin_newsletter_path(@newsletter)
  end

  protected

  def parse_time(time)
    Time.zone = 'UTC'
    Chronic.time_class = Time.zone
    Chronic.parse(time)
  end

end