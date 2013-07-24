class SetProjectDetailsOnJobOffers < Mongoid::Migration
  def self.up
    JobOffer.where(:project_details => nil).update_all(project_details: '-')
  end

  def self.down
    JobOffer.where(:project_details => '-').update_all(project_details: nil)
  end
end