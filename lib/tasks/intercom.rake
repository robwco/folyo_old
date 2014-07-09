namespace :folyo do

  namespace :intercom do

    task update_users: :environment do
      User.all.each_with_index do |u, i|
        puts "Updating user ##{i}: #{u.email}"
        u.update_intercom_attributes rescue nil
      end
    end

    task update_users_impression_date: :environment do
      User.all.order_by('$natural' => -1).each_with_index do |u, i|
        puts "Updating user ##{i}: #{u.email}"
        begin
          intercom_user = Intercom::User.find(user_id: u.id.to_s)

          if intercom_user.last_impression_at.nil? || (intercom_user.last_impression_at < 1.month.ago && intercom_user.last_impression_at < u.last_sign_in_at)
            intercom_user.last_impression_at = u.last_sign_in_at
            intercom_user.save
          end
        rescue
          puts "error with user ##{i}: #{u.email}"
        end
      end
    end

  end

end