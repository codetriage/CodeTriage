# frozen_string_literal: true

namespace :docs do
  task :play do
    parser = DocsDoctor::Runner.new('ruby/rdoc', '4.0.0').parser
    puts parser.inspect
    parser.add_files("test/fixtures/ruby/string/strip.rb")
    parser.go!
  end
end

# parser = DocsDoctor::Parser.new('ruby/rdoc', '4.0.0')
# parser.add_files("/Users/schneems/Documents/projects/rails/activesupport/lib/active_support/core_ext/string/strip.rb")
# parser.go!

# parser.files.each do |file|
#   file.classes.each do |klass|
#     klass.methods.each do |method|

#     end
#   end
# end
