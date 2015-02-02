workers ENV.fetch('WEB_CONCURRENCY') { 2 }.to_i

threads_count = ENV.fetch('MAX_THREADS') { 5 }.to_i
threads threads_count, threads_count

rackup DefaultRackup
port ENV.fetch('PORT') { 3000 }
environment ENV.fetch('RACK_ENV') { 'development' }
preload_app!

on_worker_boot do
  # worker specific setup
  ActiveRecord::Base.establish_connection

  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis = ENV["OPENREDIS_URL"] || "redis://127.0.0.1:6379"
    Rails.logger.info('Connected to Redis')
  end
end

