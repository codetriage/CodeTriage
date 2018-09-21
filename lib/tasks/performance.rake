task :compare_branches do |before, after|
  require 'pathname'
  rails_dir = Pathname.new(__dir__).join("../../..", "rails").expand_path

  before = ENV["BEFORE_BRANCH"].chomp
  after = ENV["AFTER_BRANCH"].chomp

  time = Time.now.to_s(:usec)
  out_path = Pathname.new("tmp/compare_branches/#{time}")
  out_path.mkpath
  before_file = out_path + "#{before.gsub('/', ':')}.bench.txt"
  after_file  = out_path + "#{after.gsub('/', ':')}.bench.txt"

  Dir.chdir(rails_dir) do
    run!("git checkout '#{before}'")
  end
  Dir.chdir(rails_dir) do
    run!("git checkout '#{after}'")
  end

  puts "Before branch: #{before}"
  puts "After branch: #{after}"

  100.times do
    Dir.chdir(rails_dir) { run!("git checkout '#{before}'") }
    run!(" bundle exec derailed exec perf:test 2>&1 | tail -n 1 >> '#{before_file}'")

    Dir.chdir(rails_dir) { run!("git checkout '#{after}'") }
    run!(" bundle exec derailed exec perf:test 2>&1 | tail -n 1 >> '#{after_file}'")
  end
end

def run!(cmd)
  out = `#{cmd}`
  raise "Error while running #{cmd}: #{out}" unless $?.success?
  out
end



task :compare_env do
  time = Time.now.to_s(:usec)
  out_path = Pathname.new("tmp/compare_env/#{time}")
  out_path.mkpath

  before_file = out_path + "BEFORE_ENV.bench.txt"
  after_file  = out_path + "AFTER_ENV.bench.txt"

  100.times do
    run!("BEFORE_ENV=1 bundle exec derailed exec perf:test 2>&1 | tail -n 1 >> '#{before_file}'")

    run!("AFTER_ENV=1 bundle exec derailed exec perf:test 2>&1 | tail -n 1 >> '#{after_file}'")
  end
end
