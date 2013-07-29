
source "https://rubygems.org"
ruby "2.0.0"

gem 'rails', '3.2.13'

# Core components
gem 'heroku'
gem 'unicorn'
gem 'bson_ext'

# Persistence
gem 'mongoid', '~> 3.1'
gem 'rails_autolink'
gem 'mongoid_slug'
gem 'mongoid_rails_migrations'
gem 'state_machine'
gem 'reverse_markdown'

# DJ
gem 'delayed_job'
gem 'delayed_job_mongoid'
gem 'delayed-plugins-airbrake'
gem 'jobbr', git: 'git://github.com/cblavier/jobbr.git'#, '~> 1.1.0'

# UI
gem 'haml-rails'
gem 'jquery-rails', '2.1.4'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'headjs-rails'
gem 'simple_form'
gem 'inherited_resources'
gem 'kaminari'
gem 'redcarpet'

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
gem 'mixpanel'
gem 'activemerchant' # paypal
gem 'hominid', github: 'psachs/hominid' # mailchimp
gem 'swish' # dribbble

# Email
gem 'premailer-rails'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass-rails'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'taps'
  gem 'foreman'
  gem 'zeus'
  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
end

group :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'lorem'
end
