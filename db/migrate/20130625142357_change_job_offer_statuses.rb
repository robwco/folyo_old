class ChangeJobOfferStatuses < Mongoid::Migration

  def self.up
    JobOffer.where(status: :accepted).update_all(status: :waiting_for_payment)
    JobOffer.where(status: :rejected).update_all(status: :initialized)
    JobOffer.where(status: :paid).update_all(status: :accepted)
  end

  def self.down
    JobOffer.where(status: :accepted).update_all(status: :paid)
    JobOffer.where(status: :initialized).update_all(status: :rejected)
    JobOffer.where(status: :waiting_for_payment).update_all(status: :accepted)
  end

end