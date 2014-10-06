# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require Rails.root.join('db','seeds')
require 'capybara/rspec'
require 'database_cleaner'
require 'capybara/poltergeist'
require 'sidekiq/testing'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|

  Capybara.javascript_driver = :poltergeist

  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.include Warden::Test::Helpers, devise: true
  config.include Devise::TestHelpers, type: :controller
  config.include RSpec::Rails::RequestExampleGroup, type: :feature

  DatabaseCleaner[:mongoid].strategy = :truncation

  config.before(:each) do |group|
    DatabaseCleaner.clean
    FactoryGirl.create :admin
    Sidekiq::Extensions::DelayedMailer.clear
  end

  config.before(:all, devise: true) do
    Warden.test_mode!
  end

  config.after(:each, devise: true) do
    Warden.test_reset!
  end

end
