class MixpanelWorker < Struct.new(:name, :properties, :request_env, :user_data)

  def perform

    if defined?(MIXPANEL_TOKEN)
      mixpanel = Mixpanel::Tracker.new(MIXPANEL_TOKEN, env: request_env)

      properties[:distinct_id] = user_data[:email] if user_data.has_key?(:email)
      mixpanel.track(name, properties)
      mixpanel.set(user_data[:email], user_data) if user_data.has_key?(:email)
    end

  end

end