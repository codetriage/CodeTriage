# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

begin
  require "rubocop/rake_task"

  RuboCop::RakeTask.new(:rubocop) do |task|
    task.options = ['--rails', '--display-cop-names']
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
    Rails::TestUnit::Runner.rake_run([ENV["TEST"]])
  else
    # TODO: Rails 5.1 Rails::TestUnit::Runner.rake_run(["test"], ["test/system/**/*"])
    Rails::TestUnit::Runner.rake_run(["test"])
  end
end

namespace :test do
  ["models", "helpers", "controllers", "mailers", "integration", "jobs"].each do |name|
    task name => "test:prepare" do
      $: << Rails.root.to_s + "/test"
      Rails::TestUnit::Runner.rake_run(["test/#{name}"])
    end
  end

  task generators: "test:prepare" do
    $: << Rails.root.to_s + "/test"
    Rails::TestUnit::Runner.rake_run(["test/lib/generators"])
  end

  task units: "test:prepare" do
    $: << Rails.root.to_s + "/test"
    Rails::TestUnit::Runner.rake_run(["test/models", "test/helpers", "test/unit"])
  end

  task functionals: "test:prepare" do
    $: << Rails.root.to_s + "/test"
    Rails::TestUnit::Runner.rake_run(["test/controllers", "test/mailers", "test/functional"])
  end

  desc "Run system tests only"
  task system: "test:prepare" do
    $: << Rails.root.to_s + "/test"
    Rails::TestUnit::Runner.rake_run(["test/system"])
  end
end

task default: [:rubocop, :test]

Rake::Task["assets:precompile"].enhance do
  Rake::Task["db:migrate"].invoke
  Rake::Task["db:schema:cache:dump"].invoke
end
