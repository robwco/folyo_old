class RenameBudgetRange < Mongoid::Migration
  def self.up
    JobOffer.where(budget_range: 'I need help to set a budget').update_all(budget_range: 'No precise idea yet')
  end

  def self.down
  end
end