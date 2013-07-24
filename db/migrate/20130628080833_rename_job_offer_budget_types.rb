class RenameJobOfferBudgetTypes < Mongoid::Migration
  def self.up
    JobOffer.where(budget_type: :low).update_all(budget_type: :junior)
    JobOffer.where(budget_type: :medium).update_all(budget_type: :senior)
    JobOffer.where(budget_type: :high).update_all(budget_type: :superstar)
  end

  def self.down
    JobOffer.where(budget_type: :superstar).update_all(budget_type: :high)
    JobOffer.where(budget_type: :senior).update_all(budget_type: :medium)
    JobOffer.where(budget_type: :junior).update_all(budget_type: :low)
  end
end