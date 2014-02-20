threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 16)

workers Integer(ENV['PUMA_WORKERS'] || 3)

rackup DefaultRackup
port ENV['PORT'] || 3000
environment ENV['RACK_ENV'] || 'development'
preload_app!

Thread.abort_on_exception = true

on_worker_boot do
  # worker specific setup
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end

  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    ENV["OPENREDIS_URL"] ||= "redis://127.0.0.1:6379"
    uri = URI.parse(ENV["OPENREDIS_URL"])
    Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    Rails.logger.info('Connected to Redis')
  end
end