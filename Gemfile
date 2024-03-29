source "https://rubygems.org"
ruby "2.1.5"

gem 'rails', '4.1.10'

# Rac
gem 'unicorn'
gem 'rails_12factor', group: :production
gem 'rack-timeout'
gem 'unicorn-worker-killer'

# Persistence
gem 'mongoid'
gem 'bson_ext'
gem 'rails_autolink'
gem 'mongoid_slug'
gem 'mongoid_rails_migrations'
gem 'state_machine', github: 'aganov/state_machine'
gem 'reverse_markdown'
gem 'dalli'

# DJ
gem 'jobbr', github: 'cblavier/jobbr'
gem 'sinatra', '>= 1.3.0', require: nil
gem 'sidekiq'
gem 'sidekiq-delay'

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
gem 'bootstrap-sass'

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
gem 'devise-async'
gem 'cancancan'
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

gem 'coffee-rails'
gem 'compass-rails'
gem 'sass-rails'
gem 'susy'
gem 'uglifier'
gem 'asset_sync'

group :development do
  gem 'foreman'
  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'quiet_assets'
  gem 'guard-livereload', require: false
  gem 'rack-livereload'
  gem 'coffee-rails-source-maps'
  gem 'image_optim'
end

group :test do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'lorem'
  gem 'poltergeist'
  gem 'launchy'
  gem 'spring-commands-rspec'
end
