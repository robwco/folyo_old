namespace :folyo do

  namespace :intercom do

    task update_users: :environment do
      User.all.each_with_index do |u, i|
        puts "Updating user ##{i}: #{u.email}"
        u.update_intercom_attributes rescue nil
      end
    end

  end

end