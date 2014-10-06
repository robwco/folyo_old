class EvaluationsController < ApplicationController

  load_and_authorize_resource :job_offer, id_param: :offer_id

  def edit
    @reply = @job_offer.designer_replies.where(picked: true).first
    @designer = @reply.try(:designer)
    @folyo_evaluation = FolyoEvaluation.find_or_initialize_by(user: current_user)
  end

  def update
    @reply = @job_offer.designer_replies.find(params[:reply_id])
    @reply.update_attributes(reply_params)
    unless params[:folyo_evaluation][:evaluation].blank?
      @evaluation = FolyoEvaluation.find_or_initialize_by(user: current_user)
      @evaluation.update_attributes(evluation_params)
    end
    @job_offer.rate
    redirect_to offer_path(@job_offer), notice: 'Thanks for your comments!'
  end

  def reply_params
    params[:designer_reply].permit!
  end

  def evluation_params
    params[:folyo_evaluation].permit!
  end

end
