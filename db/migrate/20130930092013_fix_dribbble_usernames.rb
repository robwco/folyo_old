class FixDribbbleUsernames < Mongoid::Migration
  def self.up
    Designer.where(dribbble_username: /http:.*/).each do |d|
      d.send(:fix_dribbble_username)
      d.save
    end
  end

  def self.down
  end
end