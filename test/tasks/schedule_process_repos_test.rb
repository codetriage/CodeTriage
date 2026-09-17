# frozen_string_literal: true

require "test_helper"
require "rake"

class ScheduleProcessReposTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake::Task.define_task(:environment)
    @rake.rake_require("schedule", ["#{Rails.root}/lib/tasks"], [])
  end

  test "enqueues a PopulateDocsJob for active repos with active doc subs" do
    repos(:issue_triage_sandbox).update_column(:docs_subscriber_count, 1)

    assert_enqueued_jobs(1, only: PopulateDocsJob) do
      @rake["schedule:process_repos"].invoke
    end
  end

  test "enqueues nothing when doc generation is disabled" do
    repos(:issue_triage_sandbox).update_column(:docs_subscriber_count, 1)
    ENV["DISABLE_DOC_GENERATION"] = "1"

    assert_no_enqueued_jobs(only: PopulateDocsJob) do
      @rake["schedule:process_repos"].invoke
    end
  ensure
    ENV.delete("DISABLE_DOC_GENERATION")
  end
end
