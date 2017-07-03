Raven.configure do |config|
  config.excluded_exceptions += ["ActiveJob::DeserializationError"]
end
