  Vero::App.init do |config|

    config.api_key = "f35fcb3f3333cc79c22684becb2e3b8c83b56ff7"
    config.secret = "4208b8c3c3e0daf865f8287f22efab2403148c44"

    if Rails.env.test?
      config.async = :none
    end

    if Rails.env.development? || Rails.env.test? || Rails.env.staging?
      config.development_mode = true
    end

  end