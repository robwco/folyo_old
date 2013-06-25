# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require Rails.root.join('db','seeds')
require 'capybara/rspec'
require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|

  config.mock_with :rspec

  DatabaseCleaner[:mongoid].strategy = :truncation

  config.before(:each) do
    Mongoid::IdentityMap.clear
  end

  config.before(:each) do |group|
    DatabaseCleaner.clean
    FactoryGirl.create :admin
  end

end
