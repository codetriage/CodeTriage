require 'bigdecimal'

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

def students_t_test(file_1, file_2)
  series_1 = values_from_benchmark(file_1)
  series_2 = values_from_benchmark(file_2)
  StatisticalTest::TTest.paired_test(alpha = 0.05, :two_tail, series_1, series_2)
end

branch_names = ["tmp/compare_branches/20190610170044486002/master.bench.txt", "tmp/compare_branches/20190610170044486002/d9a8778be852b34c4509353352865ade0a6172da.bench.txt"]

series_1 =  values_from_benchmark(branch_names[0])
series_2 = values_from_benchmark(branch_names[1])

require 'statistics'

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

  ratio = slower/faster

  if t_test[:alternative]
    puts "❤️ " * 40
  else
    puts "👎 " * 80
  end

  puts "Branch #{winner.inspect} is faster than #{loser.inspect} by\n  #{ratio.to_f}x\n\n"
  puts "P-value: #{t_test[:p_value].to_f}"
  puts "Is signifigant? (P-value < 0.05): #{t_test[:alternative]}"
