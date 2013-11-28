class TruncateDesignerBios < Mongoid::Migration
  def self.up
    Designer.all.select{|d| !d.valid?}.each do |designer|
      designer.long_bio = designer.long_bio.truncate(750)
      designer.save
    end
  end

  def self.down
  end
end