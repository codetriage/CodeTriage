# PumaAutoTune.start


require 'pathname'
require 'bigdecimal'

KB_TO_BYTE = 1024          # 2**10   = 1024
MB_TO_BYTE = 1_048_576     # 1024**2 = 1_048_576
GB_TO_BYTE = 1_073_741_824 # 1024**3 = 1_073_741_824
CONVERSION = { "kb" => KB_TO_BYTE, "mb" => MB_TO_BYTE, "gb" => GB_TO_BYTE }
ROUND_UP   = BigDecimal.new("0.5")

def linux_memory(file)
  lines = file.each_line.select {|line| line.match /^Pss/ }
  return if lines.empty?
  lines.reduce(0) do |sum, line|
    line.match(/(?<value>(\d*\.{0,1}\d+))\s+(?<unit>\w\w)/) do |m|
      value = BigDecimal.new(m[:value])
      unit  = m[:unit].downcase
      sum += CONVERSION[unit] * value
    end
    sum
  end
rescue Errno::EACCES
  0
end

def total_system_memory
  sum = 0
  Dir["/proc/*"].each do |dir|
    file =  Pathname.new(dir).join("smaps")
    sum +=  linux_memory(file) if file.exist?
  end

  (sum/BigDecimal.new(MB_TO_BYTE)).to_f
end

Thread.new do
  loop do
    sleep 10
    puts "Experiment: measure#total_memory=#{total_system_memory}"
  end
end
