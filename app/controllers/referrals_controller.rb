class ReferralsController < ApplicationController

  section :referrals

  before_filter :set_designer, :set_section

  def index
    @referral_url = "http://www.folyo.me/?ref=#{@designer.referral_token}"
    @balance = @designer.referral_balance
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

  def set_designer
    @designer = Designer.find(params[:designer_id])
  end

  def set_section
    if @designer && current_user && @designer.id == current_user.id
      @section = :account
    else
      @section = :designers
    end
  end

end