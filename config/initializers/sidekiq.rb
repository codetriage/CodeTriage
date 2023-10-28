# frozen_string_literal: true

Sidekiq.default_configuration.redis = {
  url: ENV["REDIS_URL"],
  ssl_params: {
    verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
}
