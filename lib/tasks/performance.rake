require 'bigdecimal'
require 'statistics'

def values_from_benchmark(file_name)
  file_contents = File.read(file_name)
  output = []
  file_contents.each_line do |line|
    line.match(/\( +(\d+\.\d+)\)/)
    begin
      output << BigDecimal($1)
    rescue => e
      raise e, "Problem with file #{file_name.inspect}:\n#{file_contents}\n#{e.message}"
    end
  end
  output
end


task :compare_branches do
  require 'pathname'
  rails_dir = Pathname.new(__dir__).join("../../..", "rails").expand_path
  # current_rails_branch = ""
  # Dir.chdir(rails_dir) { current_rails_branch = run!('__git_ps1').chomp.gsub(/\(\)/, "") }

  time = Time.now.to_s(:usec)
  out_path = Pathname.new("tmp/compare_branches/#{time}")
  out_path.mkpath

  branch_names = ENV.fetch("BRANCHES_TO_TEST").split(",")
  branches_to_test = branch_names.each_with_object({}) {|elem, hash| hash[elem] = out_path + "#{elem.gsub('/', ':')}.bench.txt" }
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

  break unless branches_to_test.count == 2

  series_1 = values_from_benchmark(branches_to_test[branch_names[0]])
  series_2 = values_from_benchmark(branches_to_test[branch_names[1]])

  t_test = StatisticalTest::TTest.paired_test(alpha = 0.05, :two_tail, series_1, series_2)

  avg_1 = series_1.inject(&:+) / series_1.count
  avg_2 = series_2.inject(&:+) / series_2.count

  faster = avg_1
  faster = avg_2 
  if avg_2 < avg_1
    winner = branch_names[1]
    loser  = branch_names[0]
    faster = avg_2
    slower = avg_1
  else
    winner = branch_names[0]
    loser  = branch_names[1]
    faster = avg_1
    slower = avg_2
  end

  x_faster = "%0.4f" % (slower/faster).to_f
  percent_faster = "%0.4f" % (((slower - faster) / slower).to_f  * 100)

  if t_test[:alternative]
    puts "❤️ " * 40
  else
    puts "👎 " * 80
  end

  puts "Branch #{winner.inspect} is faster than #{loser.inspect} by" 
  puts "  #{x_faster}x faster or #{percent_faster}\% faster"
  puts ""
  puts "P-value: #{t_test[:p_value].to_f}"
  puts "Is signifigant? (P-value < 0.05): #{t_test[:alternative]}"
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
