require 'mixpanel_worker'

# Common event tracking system for Vero and MixPanel services
class EventTracker < Struct.new(:name, :properties, :request_env, :user_data)

  def self.track_action(name, properties, request_env = nil)
    unless Rails.env.test?
      Delayed::Job.enqueue MixpanelWorker.new(name, properties, request_env, {}), queue: 'mixpanel'
    end
  end

  def self.track_user_action(user, name, properties, request_env = nil)
    unless Rails.env.test?
      user.track(name, properties)
      user_data = user.to_json(only: %i{email full_name created_at}, methods: %i{role profile_url})
      Delayed::Job.enqueue MixpanelWorker.new(name, properties, request_env, user_data), queue: 'mixpanel'
    end
  end

end