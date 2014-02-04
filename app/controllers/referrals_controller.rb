class ReferralsController < ApplicationController

  section :referrals

  load_and_authorize_resource :designer, except: :index_for_current_user

  before_filter :set_section

  def index
    @referral_url = "http://www.folyo.me/?ref=#{@designer.referral_token}"
    @balance = @designer.referral_balance
  end

  # Handles a www.folyo.me/referrals access (no need to hard code designer slug in url)
  # For newsletter purpose
  def index_for_current_user
    if current_user
      redirect_to designer_referrals_path(current_user)
    else
      session[:previous_url] = request.path
      flash[:error] = 'You are not authorized to access this page.'
      redirect_to sign_in_path
    end
  end

  def transfer
    @designer.paypal_email = params[:designer][:paypal_email]
    if @designer.save
      if @designer.transfer_referral_bonus
        redirect_to designer_referrals_path(@designer), notice: "Successfully transfered bonus to #{@designer.paypal_email}"
      else
        redirect_to designer_referrals_path(@designer), error: "Could not wire money :/ Please check your PayPal account or contact us."
      end
    else
      index
      render 'index'
    end
  end

  protected

  def set_section
    if @designer && current_user && @designer.id == current_user.id
      @section = :account
    else
      @section = :designers
    end
  end

end