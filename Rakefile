# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

if ENV["DEADLOCK_DEBUG"]
  Thread.new do
    loop do
      sleep ENV["DEADLOCK_DEBUG"].to_f # seconds
      puts
      puts
      puts
      puts "## Deadlock Debug"
      puts
      Thread.list.each { |t|
        puts "=" * 80
        puts t.backtrace
      }
    end
  end
end

require File.expand_path("../config/application", __FILE__)

begin
  require "rubocop/rake_task"

  RuboCop::RakeTask.new(:rubocop) do |task|
    task.options = ["--display-cop-names"]
  end
rescue LoadError
  # We are in the production environment, where Rubocop is not required.
end

CodeTriage::Application.load_tasks

task "assets:profile" do
  puts "=============="

  StackProf.run(mode: :wall, out: "tmp/stackprof.dump") do
    Rake::Task["assets:precompile"].invoke
  end
end

# $ bundle exec rake assets:bench ; cd  ~/documents/projects/sprockets; git co -; cd -; bundle exec rake assets:bench
task "assets:bench" do
  measure = []

  50.times do
    `rm -rf tmp/cache/assets/sprockets/v4.0/ ; rm -rf public/assets; touch tmp;`
    measure << Benchmark.measure do
      `time env RAILS_ENV=production bundle exec rake assets:precompile`
    end.real
  end
  puts "================ DONE ================"
  puts measure.join("\n")
end

# Use default Rails test tasks (Rails 7.1+)
task default: [:test]

Rake::Task["assets:precompile"].enhance do
  Rake::Task["db:migrate"].invoke
  Rake::Task["db:schema:cache:dump"].invoke
end
