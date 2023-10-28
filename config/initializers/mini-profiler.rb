# frozen_string_literal: true

# set RedisStore so Rack Mini-Profiler works with multiple servers
if Rails.env.production? && ENV["REDIS_URL"]
  uri = URI.parse(ENV["REDIS_URL"])
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
  Rack::MiniProfiler.config.storage_options = {host: uri.host, port: uri.port, password: uri.password}
end
