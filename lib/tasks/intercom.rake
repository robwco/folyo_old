namespace :folyo do

  namespace :intercom do

    task create_users: :environment do
      User.where(:intercom_enabled.ne => true).each do |u|
        puts "Creating user #{u.email}"
        u.send(:update_intercom_attributes, true)
        u.update_attribute(:intercom_enabled, true)
      end
    end

    task update_users: :environment do
      User.all.each_with_index do |u, i|
        puts "Updating user ##{i}: #{u.email}"
        u.send(:update_intercom_attributes, true)
      end
    end

  end

end