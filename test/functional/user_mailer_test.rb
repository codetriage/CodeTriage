# frozen_string_literal: true

require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "send_triage works" do
    repo_sub = repo_subscriptions(:schneems_to_triage)
    assignment = issue_assignments(:one)
    email = UserMailer.send_triage(
      repo: repo_sub.repo,
      user: repo_sub.user,
      assignment: assignment
    )

    assert_emails 1 do
      email.deliver_now
    end
  end

  test "poke_inactive works" do
    user = users(:schneems)
    email = UserMailer.poke_inactive(
      user: user,
      min_issue_count: 0,
      min_subscriber_count: 0
    )

    assert_emails 1 do
      email.deliver_now
    end
  end

  def daily_triage_body(user)
    email = UserMailer.send_daily_triage(user_id: user.id, assignment_ids: [], email_at: Time.now.iso8601)
    (email.text_part || email).body.to_s
  end

  test "send_daily_triage links each paused doc subscription to re-enable or change settings" do
    sub = repo_subscriptions(:write_doc_only)
    sub.update_column(:docs_last_click_at, (RepoSubscription::DOC_ACTIVITY_WINDOW + 1.day).ago)

    body = daily_triage_body(sub.user)

    signed_id = body[%r{/repo_subscriptions/([^/]+)/resume}, 1]
    assert_equal sub, RepoSubscription.find_signed(CGI.unescape(signed_id.to_s), purpose: :resume_docs)
    assert_match %r{\]\(http[^)]+/#{Regexp.escape(sub.repo.full_name)}\)}, body
  end

  test "send_daily_triage has no paused docs section when doc subscriptions are active" do
    sub = repo_subscriptions(:write_doc_only)
    sub.update_column(:docs_last_click_at, Time.current)

    refute_match %r{/resume}, daily_triage_body(sub.user)
  end
end
