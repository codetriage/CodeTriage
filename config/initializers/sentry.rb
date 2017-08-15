Raven.configure do |config|
  config.excluded_exceptions += ["Sidekiq::Shutdown"]
end
