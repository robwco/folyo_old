class SetModerationDatesOnDesigners < Mongoid::Migration
  def self.up
    Designer.all.each_with_index do |designer, index|
      puts "designer ##{index}"
      designer.applied_at = designer.created_at
      if designer.accepted?
        designer.accepted_at = designer.created_at
      elsif designer.rejected?
        designer.rejected_at = designer.updated_at
      end
      designer.save
    end
  end

  def self.down
  end
end
