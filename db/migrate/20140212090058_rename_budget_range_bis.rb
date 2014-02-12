class RenameBudgetRangeBis < Mongoid::Migration
  def self.up
    JobOffer.where(budget_range: 'No precise idea yet').update_all(budget_range: 'Not sure yet')
  end

  def self.down
  end
end