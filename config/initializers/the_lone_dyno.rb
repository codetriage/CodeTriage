class DataDump < ActiveRecord::Base
end

TheLoneDyno.exclusive do |signal|
  puts "Acquired lock in postgres"

  require 'objspace'
  require 'tempfile'

  ObjectSpace.trace_object_allocations_start
  signal.watch do |payload|
    puts "Got signal #{payload}"
    Tempfile.open("heap.dump") do |f|
      ObjectSpace.dump_all(output: f)
      size = (File.size(f).to_f / 2**20).round(2)
      puts "HeapDump Size: #{size} mb"
      ActiveRecord::Base.logger.silence do
        DataDump.create(data: File.new(f).read)
      end
    end
  end
end
