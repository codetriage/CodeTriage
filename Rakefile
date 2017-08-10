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

# overrides for bootsnap to eliminate relative paths
# TODO Rails 5.1 add test:system
%w[
  test test:prepare test:generators test:models test:helpers
  test:controllers test:mailers test:integration test:jobs
  test:units test:functionals
].each { |task| Rake::Task[task].clear }

task :test do
  $: << Rails.root.to_s + "/test"

  if ENV.key?("TEST")
    Minitest.rake_run([ENV["TEST"]])
  else
    # TODO: Rails 5.1 Minitest.rake_run(["test"], ["test/system/**/*"])
    Minitest.rake_run(["test"])
  end
end

namespace :test do
  ["models", "helpers", "controllers", "mailers", "integration", "jobs"].each do |name|
    task name => "test:prepare" do
      $: << Rails.root.to_s + "/test"
      Minitest.rake_run(["test/#{name}"])
    end
  end

  task generators: "test:prepare" do
    $: << Rails.root.to_s + "/test"
    Minitest.rake_run(["test/lib/generators"])
  end

  task units: "test:prepare" do
    $: << Rails.root.to_s + "/test"
    Minitest.rake_run(["test/models", "test/helpers", "test/unit"])
  end

  task functionals: "test:prepare" do
    $: << Rails.root.to_s + "/test"
    Minitest.rake_run(["test/controllers", "test/mailers", "test/functional"])
  end

  desc "Run system tests only"
  task system: "test:prepare" do
    $: << Rails.root.to_s + "/test"
    Minitest.rake_run(["test/system"])
  end
end

namespace :rubocop do
  require 'rubocop/rake_task'
  options = ['--rails','--display-cop-names']

  desc 'Run RuboCop on new git files against aster'
  RuboCop::RakeTask.new(:new) do |task|
    task.patterns = `git diff --name-only HEAD $(git merge-base HEAD master)`.split("\n")
    task.options = options
  end

  desc 'Run RuboCop on all files'
  RuboCop::RakeTask.new(:all) do |task|
    task.options = options
  end
end
