class AddClientAttributesToJobOffers < Mongoid::Migration
  def self.up
    JobOffer.all.each do |o|
      o.location = o.client.try(:location)
      o.company_name = o.client.try(:company_name )
      o.company_url = o.client.try(:company_url)
      o.company_description = o.client.try(:company_description)
      o.save
    end
  end

  def self.down
  end
end