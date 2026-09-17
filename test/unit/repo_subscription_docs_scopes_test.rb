# frozen_string_literal: true

require "test_helper"

class RepoSubscriptionDocsScopesTest < ActiveSupport::TestCase
  # write_doc_only is the only fixture with write=true persisted; the others
  # (schneems_to_triage, read_doc_only) set only limits, which fixtures do not
  # translate into the read/write booleans, so they are NOT in the docs scope.
  test "docs scope selects only read-or-write subscriptions" do
    assert_includes RepoSubscription.docs, repo_subscriptions(:write_doc_only)
    refute_includes RepoSubscription.docs, repo_subscriptions(:schneems_to_triage)
    refute_includes RepoSubscription.docs, repo_subscriptions(:read_doc_only)
  end

  test "active_docs excludes a doc sub with a stale docs_last_click_at" do
    sub = repo_subscriptions(:write_doc_only)

    sub.update_column(:docs_last_click_at, Time.current)
    assert_includes RepoSubscription.active_docs, sub

    sub.update_column(:docs_last_click_at, (RepoSubscription::DOC_ACTIVITY_WINDOW + 1.day).ago)
    refute_includes RepoSubscription.active_docs, sub
  end

  test "inactive_docs_needing_reopt_in selects stale, un-notified doc subs only" do
    sub = repo_subscriptions(:write_doc_only)

    sub.update_columns(
      docs_last_click_at: (RepoSubscription::DOC_ACTIVITY_WINDOW + 1.day).ago,
      docs_reopt_in_sent_at: nil
    )
    assert_includes RepoSubscription.inactive_docs_needing_reopt_in, sub

    # already notified this episode -> excluded
    sub.update_column(:docs_reopt_in_sent_at, Time.current)
    refute_includes RepoSubscription.inactive_docs_needing_reopt_in, sub

    # active again -> excluded
    sub.update_columns(docs_last_click_at: Time.current, docs_reopt_in_sent_at: nil)
    refute_includes RepoSubscription.inactive_docs_needing_reopt_in, sub
  end
end
