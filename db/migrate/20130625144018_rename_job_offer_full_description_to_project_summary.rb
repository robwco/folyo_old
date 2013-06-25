class RenameJobOfferFullDescriptionToProjectSummary < Mongoid::Migration

  def self.up
    JobOffer.all.each do |offer|
      offer.rename(:full_description, :project_summary)
    end
  end

  def self.down
    JobOffer.all.each do |offer|
      offer.rename(:project_summary, :full_description)
    end
  end

end