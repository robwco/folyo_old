class FixDribbbleUsernames < Mongoid::Migration
  def self.up
    Designer.where(dribbble_username: /http:.*/).each do |d|
      begin
        d.send(:fix_dribbble_username)
        d.save
      rescue
      end
    end
  end

  def self.down
  end
end