  Vero::App.init do |config|

    config.api_key = "f35fcb3f3333cc79c22684becb2e3b8c83b56ff7"
    config.secret = "4208b8c3c3e0daf865f8287f22efab2403148c44"

    if Rails.env.test?
      config.async = :none
    elsif Rails.env.staging?
      config.async = :thread
    else
      config.async = :delayed_job
    end

    if Rails.env.development? || Rails.env.test? || Rails.env.staging?
      config.development_mode = true
    end

  end