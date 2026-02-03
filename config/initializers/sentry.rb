# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.excluded_exceptions += ["Sidekiq::Shutdown"]

  # Set traces_sample_rate to capture performance data
  config.traces_sample_rate = 0.1
end
