# tested max in production is 9
WEB_CONCURRENCY = Integer(ENV['WEB_CONCURRENCY']|| 2)

worker_processes WEB_CONCURRENCY
timeout 30
preload_app true

before_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end

end

after_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end

  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    ENV["OPENREDIS_URL"] ||= "redis://127.0.0.1:6379"
    uri = URI.parse(ENV["OPENREDIS_URL"])
    Resque.redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
    Rails.logger.info('Connected to Redis')
  end
end
