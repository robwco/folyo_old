class BudgetsController < ApplicationController

  def estimate
    @skills_with_statistics = BudgetSurveyData.skills_with_statistics
  end

end
