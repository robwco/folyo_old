class SetReferralTokenOnDesigners < Mongoid::Migration
  def self.up
    Designer.all.each do |designer|
      designer.send(:set_referral_token)
      designer.save
    end
  end

  def self.down
  end
end