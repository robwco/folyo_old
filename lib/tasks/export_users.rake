namespace :folyo do

  desc 'Export all users as a csv'
  task export_users: :environment do
    CSV.open('./users.csv', 'w:UTF-8', {col_sep: ';'}) do |csv|
      attributes = %w(id email full_name role status slug company_name created_at)
      csv << attributes
      User.all.each do |user|
        csv << attributes.map{|attr| user.send(attr) rescue '' }
      end
    end
  end

end