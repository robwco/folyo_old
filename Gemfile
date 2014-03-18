source "https://rubygems.org"
ruby "2.0.0"

gem 'rails', '3.2.16'

# Core components
gem 'heroku'
gem 'unicorn'
gem 'bson_ext'

# Persistence
gem 'mongoid'
gem 'rails_autolink'
gem 'mongoid_slug'
gem 'mongoid_rails_migrations'
gem 'state_machine'
gem 'reverse_markdown'
gem 'dalli'

# DJ
gem 'delayed_job'
gem 'delayed_job_mongoid', github: 'collectiveidea/delayed_job_mongoid'
gem 'delayed-plugins-airbrake'
gem 'jobbr', '1.1.5'

# UI
gem 'haml-rails'
gem 'jquery-rails', '2.1.4'
gem 'turbolinks'
gem 'headjs-rails'
gem 'simple_form'
gem 'inherited_resources'
gem 'kaminari'
gem 'redcarpet'
gem 'chronic_duration'
gem 'font-awesome-rails'
gem 'zeroclipboard-rails'

# Upload
gem 'aws-sdk' # S3 API
gem 'carrierwave'
gem 'paperclip' # file attachment syntax and callbacks
gem 'mongoid-paperclip', require: "mongoid_paperclip"
gem 's3_direct_upload' # direct upload form helper and assets
gem 'rmagick', require: false

# Monitoring
gem 'airbrake'
gem 'newrelic_rpm'

# Security
gem 'devise'
gem 'cancan'
gem 'sanitize'

# External APIs
gem 'vero'
gem 'twitter'
gem 'geocoder'
gem 'activemerchant' # paypal
gem 'mailchimp-api'
gem 'swish' # dribbble
gem 'intercom'
gem 'intercom-rails'

# Email
gem 'premailer-rails'

# SEO
gem 'sitemap_generator'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'compass-rails'
  gem 'susy'
  gem 'uglifier'
  gem 'sprockets-image_compressor'
  gem 'asset_sync'
  gem 'turbo-sprockets-rails3'
end

group :development do
  gem 'taps'
  gem 'foreman'
  gem 'zeus'
  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'quiet_assets'
end

group :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'lorem'
  gem 'poltergeist'
end
