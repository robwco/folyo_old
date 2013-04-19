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
      user_data = {email: user.email, full_name: user.full_name, created_at: user.created_at, role: user.role, profile_url: user.profile_url}
      Delayed::Job.enqueue MixpanelWorker.new(name, properties, request_env, user_data), queue: 'mixpanel'
    end
  end

end