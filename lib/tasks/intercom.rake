namespace :folyo do

  namespace :intercom do

    task update_users: :environment do
      found = 0
      not_found = 0
      CSV.open('./intercom-deleted-users.csv', 'w:UTF-8', {col_sep: ';'}) do |csv|
        Intercom::User.all.each do |user|
          if u = User.where(email: user.email).limit(1).first
            puts "Updating user #{user.email}"
            u.send(:update_intercom_attributes, true, true)
            u.update_attribute(:intercom_enabled, true)
            found += 1
          else
            puts "Deleting user #{user.email}"
            csv <<  [user.intercom_id, user.email]
            Intercom::User.delete(email: user.email) rescue false
            not_found += 1
          end
        end
      end
      puts "Found: #{found} - Not found: #{not_found}"
    end

    task create_users: :environment do
      User.where(:intercom_enabled.ne => true).each do |u|
        puts "Creating user #{u.email}"
        u.send(:update_intercom_attributes, true)
        u.update_attribute(:intercom_enabled, true)
      end
    end
  end

end