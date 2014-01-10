class SetVeroIdOnUsers < Mongoid::Migration
  def self.up
    count = Designer.count
    Designer.all.each do |u|
      puts "#{count} designers to go" if count % 100 == 0
      u.set_vero_attributes_by_email
      count -= 1
    end

    count = Client.count
    Client.all.each do |u|
      puts "#{count} clients to go" if count % 100 == 0
      u.set_vero_attributes_by_email
      count -= 1
    end
  end

  def self.down
  end
end