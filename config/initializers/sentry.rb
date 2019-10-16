# frozen_string_literal: true

Raven.configure do |config|
  config.excluded_exceptions += ["Sidekiq::Shutdown"]

  config.async = lambda do |event|
    if ENV["DYNO"] && ENV["DYNO"].start_with?("web")
      SentryJob.perform_later(event)
    else
      Raven.send_event(event) # Already running in the background
    end
  end
end
