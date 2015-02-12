ENV["OPENREDIS_URL"] ||= "redis://127.0.0.1:6379"
uri = URI.parse(ENV["OPENREDIS_URL"])
Resque.redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
Rails.logger.info('Connected to Redis')