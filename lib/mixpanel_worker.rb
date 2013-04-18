class MixpanelWorker < Struct.new(:name, :properties, :request_env, :user_data)

  def perform

    if defined?(MIXPANEL_TOKEN)
      mixpanel = Mixpanel::Tracker.new(MIXPANEL_TOKEN, env: request_env)

      mixpanel.track(name, properties)

      unless user_data.empty?
        mixpanel.set(user_data['email'], {
          email:       user_data['email'],
          created_at:  user_data['created_at'],
          role:        user_data['role'],
          profile_url: user_data['profile_url']
        })
      end
    end

  end

end