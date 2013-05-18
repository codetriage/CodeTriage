namespace 'test' do
  desc "Run the javascript test"
  task :javascript => :environment do
    require "teabag/console"
    puts "\n\n===== Starting Javascript Test =====\n\n"
    fail if Teabag::Console.new({suite: ENV["suite"]}).execute
    puts "===== Javascript Test Complete =====\n\n\n"
  end
end

Rake::Task[:test].enhance(['test:javascript'])