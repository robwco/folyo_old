class SetPaypalEmailOnDesigners < Mongoid::Migration
  def self.up
    Designer.all.each do |d|
      d.update_attribute(:paypal_email, d.email)
    end
  end

  def self.down
  end
end