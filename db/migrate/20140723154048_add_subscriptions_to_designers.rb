class AddSubscriptionsToDesigners < Mongoid::Migration
  def self.up
    Designer.update_all(subscription_mode: :all_offers)
  end

  def self.down
  end
end
