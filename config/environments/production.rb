Folyo::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true
  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # turbo-sprockets-rails3 assets cleanup
  config.assets.expire_after 2.weeks

  config.assets.cache_store = :dalli_store

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"
  #config.action_controller.asset_host = "//folyo-production.s3.amazonaws.com"
  config.action_controller.asset_host = "//assets%d.folyo.me"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  HOST = 'www.folyo.me'

  # Devise default URL for this environment
  config.action_mailer.default_url_options = { :host => HOST }
  Rails.application.routes.default_url_options[:host] = HOST

  # SendGrid settings
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address        => "smtp.mandrillapp.com",
    :port           => "587",
    :authentication => :plain,
    :user_name      => ENV['MANDRILL_USERNAME'],
    :password       => ENV['MANDRILL_APIKEY'],
    :domain         => 'heroku.com'
  }

  config.after_initialize do
    paypal_options = {
      :login => 'robwilliamsgd_api1.gmail.com',
      :password => 'L42LE3YEN6EA2AJ8',
      :signature => 'Ap1BMCUj-Ced0xjxfOQKNUmxy7-UAOj7.3R70Py915z40tI-TIrO2fsR'
    }
    ::EXPRESS_GATEWAY = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)
  end

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
end
