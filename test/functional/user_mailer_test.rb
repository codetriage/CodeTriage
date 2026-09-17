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

  test "resume_docs renders and links to the repo" do
    repo_sub = repo_subscriptions(:write_doc_only)
    email = UserMailer.resume_docs(repo_subscription: repo_sub)

    assert_emails 1 do
      email.deliver_now
    end
    assert_match repo_sub.repo.full_name, email.html_part.body.to_s
    assert_match "/resume", email.html_part.body.to_s
  end
end
