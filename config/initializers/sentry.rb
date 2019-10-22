# frozen_string_literal: true

Raven.configure do |config|
  config.excluded_exceptions += ["Sidekiq::Shutdown"]

  config.async = lambda do |event|
    Thread.new do
      Raven.send_event(event)
    end
  end
end
