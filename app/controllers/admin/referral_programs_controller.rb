class Admin::ReferralProgramsController < ApplicationController

  section :clients

  inherit_resources

  def show
    redirect_to edit_admin_referral_program_path(@referral_program)
  end

  def new
    @referral_program = Admin::ReferralProgram.create
    redirect_to edit_admin_referral_program_path(@referral_program)
  end

  def update
    update! { edit_admin_referral_program_path(@referral_program)}
  end

end
