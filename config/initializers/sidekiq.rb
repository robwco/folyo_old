Sidekiq.hook_rails!

if Rails.env.staging? || Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDISCLOUD_URL'] }
  end
end