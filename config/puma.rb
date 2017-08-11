# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum, this matches the default thread size of Active Record.
#
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
threads threads_count, threads_count

rackup DefaultRackup

# Specifies the `port` that Puma will listen on to receive requests, default is 3000.
#
port        ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
#
preload_app!

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted this block will be run, if you are using `preload_app!`
# option you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, Ruby
# cannot share connections between processes.
#
# on_worker_boot do
#   ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
# end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

on_worker_boot do
  # worker specific setup
  ActiveRecord::Base.establish_connection

  # Sidekiq doesn't create connections until you try to do something https://github.com/mperham/sidekiq/issues/627#issuecomment-20366059

  if ENV['AWS_ACCESS_KEY_ID']

    TheLoneDyno.exclusive do |signal|
      puts "Running on DYNO: #{ENV['DYNO']}"

      require 'objspace'
      require 'tempfile'

      ObjectSpace.trace_object_allocations_start
      signal.watch do |payload|
        puts "Got signal #{payload}"
        Tempfile.open("heap.dump") do |f|
          ObjectSpace.dump_all(output: f)
          f.close

          s3 = Aws::S3::Client.new(region: 'us-east-1')
          File.open(f, 'rb') do |file|
            s3.put_object(body: file, key: "#{Time.now.iso8601}-process:#{Process.pid}-heap.dump", bucket: "heap-dumps-schneems")
          end
        end
      end
    end
  end
end
