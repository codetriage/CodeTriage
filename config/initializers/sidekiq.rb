# frozen_string_literal: true

sidekiq_config = {
  url: ENV["REDIS_URL"],
  ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE}
}

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end

if Sidekiq.server?
  Rails.application.config.active_record.warn_on_records_fetched_greater_than = 1500
end
