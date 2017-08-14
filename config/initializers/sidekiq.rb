unless Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV["REDIS_URL"], namespace: "codetriage-sidekiq" }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV["REDIS_URL"], namespace: "codetriage-sidekiq" }
  end
end
