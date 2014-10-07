class DenormalizeFieldsOnSurveys < Mongoid::Migration

  def self.up
    Survey.all.each do |survey|
      survey.user_full_name = survey.user.full_name rescue nil
      survey.user_location = survey.user.location rescue nil
      survey.save
    end
  end

  def self.down
  end

end