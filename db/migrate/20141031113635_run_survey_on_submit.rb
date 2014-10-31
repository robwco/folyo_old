class RunSurveyOnSubmit < Mongoid::Migration
  def self.up
    Survey.submitted.each do |survey|
      survey.on_submit
    end
  end

  def self.down
  end
end