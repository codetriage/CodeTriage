Raven.configure do |config|
  config.excluded_exceptions += ["Sidekiq::Shutdown"]
  config.async = lambda { |event|
    SentryJob.perform_later(event)
  }
end
