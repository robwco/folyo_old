class SurveysController < ApplicationController

  before_filter :set_survey_params, :set_survey

  layout 'surveys_layout'

  def show
    if @survey_page.blank?
      redirect_to "/surveys/#{@survey_name}/intro"
    else
      render "/surveys/#{@survey_name}/#{@survey_page}"
    end
  end

  def update
    @survey.update_attributes(params[:survey])
    redirect_to "/surveys/#{@survey_name}/#{@survey_page}"
  end

  protected

  def set_survey_params
    @survey_name ||= params[:survey_name]
    @survey_page ||= params[:page]
  end

  def set_survey
    @survey ||= Survey.find_or_create_by(name: @survey_name, user: current_user)
  end

end
