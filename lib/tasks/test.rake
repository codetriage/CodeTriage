# namespace 'test' do
#   desc "Run the javascript test"
#   task javascript: :environment do
#     require "teaspoon/console"
#     puts "\n\n===== Starting Javascript Test =====\n\n"
#     fail if Teaspoon::Console.new({suite: ENV["suite"]}).execute
#     puts "===== Javascript Test Complete =====\n\n\n"
#   end
# end

# Rake::Task[:test].enhance(['test:javascript'])
