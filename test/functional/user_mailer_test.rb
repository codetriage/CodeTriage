# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "send_triage works" do
    repo_sub = repo_subscriptions(:schneems_to_triage)
    assignment = issue_assignments(:one)
    email = UserMailer.send_triage(repo: repo_sub.repo, user: repo_sub.user, assignment: assignment)

    assert_emails 1 do
      email.deliver_now
    end
  end

  test "poke_inactive works" do
    user = users(:schneems)
    email = UserMailer.poke_inactive(user: user)

    assert_emails 1 do
      email.deliver_now
    end
  end
end
