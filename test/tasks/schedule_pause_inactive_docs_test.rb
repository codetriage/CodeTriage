# frozen_string_literal: true

require "test_helper"
require "rake"

class SchedulePauseInactiveDocsTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake::Task.define_task(:environment)
    @rake.rake_require("schedule", ["#{Rails.root}/lib/tasks"], [])
  end

  test "emails inactive doc subscribers a re-opt-in and stamps them" do
    stale = repo_subscriptions(:write_doc_only)
    stale.update_columns(
      docs_last_click_at: (RepoSubscription::DOC_ACTIVITY_WINDOW + 1.day).ago,
      docs_reopt_in_sent_at: nil
    )

    assert_enqueued_emails 1 do
      @rake["schedule:pause_inactive_docs"].invoke
    end

    assert_not_nil stale.reload.docs_reopt_in_sent_at
  end

  test "does not email active doc subscribers" do
    active = repo_subscriptions(:write_doc_only)
    active.update_columns(docs_last_click_at: Time.current, docs_reopt_in_sent_at: nil)

    assert_no_enqueued_emails do
      @rake["schedule:pause_inactive_docs"].invoke
    end
  end

  test "does nothing when doc generation is disabled via the kill switch" do
    stale = repo_subscriptions(:write_doc_only)
    stale.update_columns(
      docs_last_click_at: (RepoSubscription::DOC_ACTIVITY_WINDOW + 1.day).ago,
      docs_reopt_in_sent_at: nil
    )

    ENV["DISABLE_DOC_GENERATION"] = "1"
    begin
      assert_no_enqueued_emails do
        @rake["schedule:pause_inactive_docs"].invoke
      end
    ensure
      ENV.delete("DISABLE_DOC_GENERATION")
    end

    assert_nil stale.reload.docs_reopt_in_sent_at
  end
end
