#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

CodeTriage::Application.load_tasks


task "assets:profile" do
  puts "=============="

  StackProf.run(mode: :wall, out: "tmp/stackprof.dump") do
    Rake::Task["assets:precompile"].invoke
  end
end



task "assets:bench" do
  measure = []

  50.times do
    measure << Benchmark.measure do
      `rm -rf tmp/cache/assets/sprockets/v4.0/ ; rm -rf public/assets; touch tmp; time RAILS_ENV=production bundle exec rake assets:precompile`
    end.real
  end
  puts "================ DONE ================"
  puts measure.join("\n")
end