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

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
