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
    update! { edit_admin_newsletter_path(@newsletter) }
    if params['send-test']
      @newsletter.send_test(current_user.email)
      flash[:notice] = "Newsletter has been updated and sent to #{current_user.email}"
    elsif params['fire']
      @newsletter.fire!
      flash[:notice] = "Newsletter has been updated and sent to designers!"
    end
  end

  def show
    redirect_to edit_admin_newsletter_path(@newsletter)
  end

end