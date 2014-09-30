class SurveysController < ApplicationController

  before_filter :set_survey_params, :set_survey

  layout 'surveys_layout'

  def show
    if @survey_page.blank?
      redirect_to "/surveys/#{@survey_name}/#{default_first_page}"
    else
      if @survey_page == default_last_page
        @survey.submit
      end
      render "/surveys/#{@survey_name}/#{@survey_page}"
    end
  end

  def update
    @survey.update_attributes(params[:survey])
    redirect_to "/surveys/#{@survey_name}/#{@survey_page}"
  end

  protected

  def default_first_page
    '00-introduction'
  end

  def default_last_page
    '10-thanks'
  end


  def set_survey_params
    @survey_name ||= params[:survey_name]
    @survey_page ||= params[:page]
  end

  def set_survey
    class_name = "#{@survey_name}_survey".camelize
    klass = Object.const_get(class_name) rescue Survey
    @survey ||= klass.send(:find_or_create_by, { name: @survey_name, user: current_user })
  end

end
