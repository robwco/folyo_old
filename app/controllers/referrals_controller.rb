class ReferralsController < ApplicationController

  section :referrals

  before_filter :set_designer

  def index
    @referral_url = "http://www.folyo.me/referrals/#{@designer.referral_token}"
    @referrals = @designer.referrals
  end

  protected

  def set_designer
    @designer = Designer.find(params[:designer_id])
  end

end