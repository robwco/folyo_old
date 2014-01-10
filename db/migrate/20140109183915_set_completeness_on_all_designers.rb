class SetCompletenessOnAllDesigners < Mongoid::Migration
  def self.up
    count = Designer.count
    Designer.all.each do |designer|
      puts "#{count} designers to go" if count % 100 == 0
      designer.set_completeness
      count -= 1
    end
  end

  def self.down
  end
end