task :compare_branches do
  require 'pathname'
  rails_dir = Pathname.new(__dir__).join("../../..", "rails").expand_path
  # current_rails_branch = ""
  # Dir.chdir(rails_dir) { current_rails_branch = run!('__git_ps1').chomp.gsub(/\(\)/, "") }

  time = Time.now.to_s(:usec)
  out_path = Pathname.new("tmp/compare_branches/#{time}")
  out_path.mkpath

  branches_to_test = ENV.fetch("BRANCHES_TO_TEST").split(",").each_with_object({}) {|elem, hash| hash[elem] = out_path + "#{elem.gsub('/', ':')}.bench.txt" }
  script = ENV["DERAILED_SCRIPT"] || "bundle exec derailed exec perf:test"

  # Make sure the branch exists and the script runs on it
  branches_to_test.each do |branch, file|
    Dir.chdir(rails_dir) { run!("git checkout '#{branch}'") }
    run!("#{script}")
  end

  COUNT = 100
  COUNT.times do |i|
    puts "#{i.next}/#{COUNT}"
    branches_to_test.each do |branch, file|
      Dir.chdir(rails_dir) { run!("git checkout '#{branch}'") }
      run!(" #{script} 2>&1 | tail -n 1 >> '#{file}'")
    end
  end
ensure
  # Dir.chdir(rails_dir) { run!("git checkout '#{current_rails_branch}") } if current_rails_branch
end

def run!(cmd)
  out = `#{cmd}`
  raise "Error while running #{cmd.inspect}: #{out}" unless $?.success?
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
