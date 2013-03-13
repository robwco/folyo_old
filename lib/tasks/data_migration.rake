namespace :migration do

  desc 'Migrate all'
  task :all => :environment do
    %w(designers clients admins messages job_offers designer_replies orders).each do |task_name|
      Rake::Task["migration:#{task_name}"].execute
    end
  end

  desc 'Migrate all designers'
  task :designers => :environment do
    puts "#{AR::Designer.count} designers to migrate from PostgreSQL DB"

    puts "Removing #{::Designer.count} existing designers from MongoDB"
    ::Designer.destroy_all

    AR::Designer.order('created_at ASC').all.each_with_index do |ar_designer, i|
      puts "#{i} - Migrating #{ar_designer.user.full_name}"
      mongo_designer = ::Designer.new

      mongo_designer.pg_id = ar_designer.user.id
      mongo_designer.designer_pg_id = ar_designer.id

      %w(full_name role referrer email reset_password_token reset_password_sent_at
        remember_created_at sign_in_count current_sign_in_at current_sign_in_ip last_sign_in_at last_sign_in_ip).each do |attr|
        ar_attribute = ar_designer.user.send(attr)
        mongo_designer.send("#{attr}=", ar_attribute)
      end

      # password is overwritten at the end of the process, bypassing model validation
      mongo_designer.password = 'foobarfoo'
      mongo_designer.password_confirmation = 'foobarfoo'

      %w(created_at updated_at short_bio long_bio location minimum_budget rate portfolio_url linkedin_url twitter_username
        behance_username skype_username zerply_username featured_shot featured_shot_url featured_shot_page).each do |attr|
        ar_attribute = ar_designer.send(attr)
        mongo_designer.send("#{attr}=", ar_attribute)
      end

      mongo_designer.status = ar_designer.status.name.downcase.to_sym
      mongo_designer.profile_type = ar_designer.profile_type.name.downcase.to_sym
      mongo_designer.dribbble_username = ar_designer.dribble_username

      mongo_designer.skills = ar_designer.skills.map { |skill| skill.name.parameterize.underscore.to_sym }

      mongo_designer.coordinates = ar_designer.coordinates.split(',') unless ar_designer.coordinates.nil?

      ar_designer.designer_posts.each do |ar_post|
        mongo_post = ::DesignerPost.new
        %w(comment duration availability_date location relocate minimum_budget job_type coding weekly_hours).each do |attr|
          ar_attribute = ar_post.send(attr)
          mongo_post.send("#{attr}=", ar_attribute)
        end
        mongo_post.status = ar_post.status.name.downcase.to_sym
        mongo_designer.posts << mongo_post
        mongo_post.save!
      end

      mongo_designer.save!

      mongo_designer.update_attribute(:encrypted_password, ar_designer.user.encrypted_password)
    end
  end

  desc 'Migrate all clients'
  task :clients => :environment do
    puts "#{AR::Client.count} clients to migrate from PostgreSQL DB"

    puts "Removing #{::Client.count} existing clients from MongoDB"
    ::Client.destroy_all

    AR::Client.order('created_at ASC').all.each_with_index do |ar_client, i|
      puts "#{i} - Migrating #{ar_client.user.full_name}"
      mongo_client = ::Client.new

      mongo_client.pg_id = ar_client.user.id
      mongo_client.client_pg_id = ar_client.id

      %w(full_name role referrer email reset_password_token reset_password_sent_at
        remember_created_at sign_in_count current_sign_in_at current_sign_in_ip last_sign_in_at last_sign_in_ip).each do |attr|
        ar_attribute = ar_client.user.send(attr)
        mongo_client.send("#{attr}=", ar_attribute)
      end

      # password is overwritten at the end of the process, bypassing model validation
      mongo_client.password = 'foobarfoo'
      mongo_client.password_confirmation = 'foobarfoo'

      %w(created_at updated_at location company_name company_url company_description twitter_username).each do |attr|
        ar_attribute = ar_client.send(attr)
        mongo_client.send("#{attr}=", ar_attribute)
      end

      mongo_client.save!

      mongo_client.update_attribute(:encrypted_password, ar_client.user.encrypted_password)
    end
  end

  desc 'Migrate all admins'
  task :admins => :environment do
    ar_admins = AR::User.order('created_at ASC').all.select{|u|u.role.downcase == 'admin'}
    puts "#{ar_admins.length} admins to migrate from PostgreSQL DB"

    puts "Removing #{::Admin.count} existing admins from MongoDB"
    ::Admin.destroy_all

    ar_admins.each_with_index do |ar_admin, i|
      puts "#{i} - Migrating #{ar_admin.full_name}"
      mongo_admin = ::Admin.new

      mongo_admin.pg_id = ar_admin.id

      %w(created_at updated_at full_name role referrer email reset_password_token reset_password_sent_at
        remember_created_at sign_in_count current_sign_in_at current_sign_in_ip last_sign_in_at last_sign_in_ip).each do |attr|
        ar_attribute = ar_admin.send(attr)
        mongo_admin.send("#{attr}=", ar_attribute)
      end

      # password is overwritten at the end of the process, bypassing model validation
      mongo_admin.password = 'foobarfoo'
      mongo_admin.password_confirmation = 'foobarfoo'

      mongo_admin.save!

      mongo_admin.update_attribute(:encrypted_password, ar_admin.encrypted_password)
    end
  end

  desc 'Migrate all messages'
  task :messages => :environment do
    puts "#{AR::Message.count} messages to migrate from PostgreSQL DB"

    puts "Removing #{::Message.count} existing messages from MongoDB"
    ::Message.destroy_all

    AR::Message.order('created_at ASC').all.each_with_index do |ar_message, i|
      ar_from_user = ar_message.from_user
      ar_to_user = ar_message.to_user
      puts "#{i} - Migrating message from #{ar_from_user.full_name} to #{ar_to_user.full_name}"

      mongo_message = ::Message.new
      mongo_message.created_at = ar_message.created_at
      mongo_message.updated_at = ar_message.updated_at
      mongo_message.comment = ar_message.comment
      mongo_message.from_user = ::User.where(pg_id: ar_from_user.id).first
      mongo_message.to_user = ::User.where(pg_id: ar_to_user.id).first
      mongo_message.save!
    end
  end

  desc 'Migrate all job offers'
  task :job_offers => :environment do
    puts "#{AR::JobOffer.count} job offers to migrate from PostgreSQL DB"

    puts "Removing #{::JobOffer.count} existing job offers from MongoDB"
    ::JobOffer.destroy_all

    AR::JobOffer.order('created_at ASC').all.each_with_index do |ar_offer, i|
      puts "#{i} - Migrating #{ar_offer.title}"
      mongo_offer = ::JobOffer.new

      mongo_offer.pg_id = ar_offer.id

      %w(created_at updated_at title full_description compensation comp_high  budget_range
         discount discount_amount is_open approved_at paid_at archived_at refunded_at).each do |attr|
        ar_attribute = ar_offer.send(attr)
        mongo_offer.send("#{attr}=", ar_attribute)
      end

      mongo_offer.skills = ar_offer.skills.map { |skill| skill.name.parameterize.underscore.to_sym }
      mongo_offer.location_type = ar_offer.location_type.name.downcase.to_sym if ar_offer.location_type
      mongo_offer.work_type = ar_offer.work_type.name.downcase.to_sym if ar_offer.work_type
      mongo_offer.status = ar_offer.status.name.downcase.to_sym if ar_offer.status

      mongo_offer.coding = :not_needed  if ar_offer.coding == 1
      mongo_offer.coding = :optional    if ar_offer.coding == 2
      mongo_offer.coding = :mandatory   if ar_offer.coding == 3

      mongo_offer.budget_type = :low    if ar_offer.budget_type == 1
      mongo_offer.budget_type = :medium if ar_offer.budget_type == 2
      mongo_offer.budget_type = :high   if ar_offer.budget_type == 3

      mongo_offer.sent_out_at = ar_offer.date_sent_out

      mongo_offer.client = ::Client.where(client_pg_id: ar_offer.id).first

      mongo_offer.save!
    end
  end

  desc 'Migrate all designer replies'
  task :designer_replies => :environment do
    puts "#{AR::DesignerReply.count} designer replies to migrate from PostgreSQL DB"

    AR::DesignerReply.order('created_at ASC').all.each_with_index do |ar_reply, i|
      mongo_offer = ::JobOffer.where(pg_id: ar_reply.job_offer_id).first
      mongo_designer = ::Designer.where(pg_id: ar_reply.user_id).first
      if mongo_offer && mongo_designer
        puts "#{i} - Migrating #{mongo_offer.title} - #{mongo_designer.full_name}"

        mongo_reply = ::DesignerReply.new
        mongo_reply.pg_id = ar_reply.id

        mongo_reply.created_at = ar_reply.created_at
        mongo_reply.updated_at = ar_reply.updated_at
        mongo_reply.designer = mongo_designer
        mongo_reply.message = ar_reply.message
        mongo_reply.collapsed = ar_reply.collapsed
        mongo_reply.picked = ar_reply.picked

        ar_evaluation = AR::Evaluation.where(job_offer_id: mongo_offer.pg_id, user_id: mongo_designer.pg_id).first
        if ar_evaluation
          mongo_reply.evaluation = ar_evaluation.evaluation
        end

        mongo_offer.designer_replies << mongo_reply
        mongo_offer.save!
      end
    end
  end

  desc 'Migrate all orders'
  task :orders => :environment do
    puts "#{AR::Order.count} orders to migrate from PostgreSQL DB"

    AR::Order.order('created_at ASC').all.each_with_index do |ar_order, i|
      mongo_offer = ::JobOffer.where(pg_id: ar_order.job_offer_id).first
      if mongo_offer
        puts "#{i} - Migrating order for #{mongo_offer.title}"

        mongo_order = ::Order.new
        mongo_order.pg_id = ar_order.id

        %w(created_at updated_at express_token express_payer_id ip_address email details total).each do |attr|
          ar_attribute = ar_order.send(attr)
          mongo_order.send("#{attr}=", ar_attribute)
        end

        mongo_offer.order = mongo_order
        mongo_offer.save!
      end
    end
  end

end