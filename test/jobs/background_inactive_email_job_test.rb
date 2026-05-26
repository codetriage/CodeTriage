# frozen_string_literal: true

require "test_helper"

class BackgroundInactiveEmailJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "sends poke_inactive email for user without subscriptions" do
    user = users(:mockstar)
    assert_predicate user.repo_subscriptions, :blank?

    assert_emails 1 do
      BackgroundInactiveEmailJob.perform_now(
        user,
        min_issue_count: 0,
        min_subscriber_count: 0
      )
    end
  end

  test "does not send email when user has active repo subscriptions" do
    user = users(:schneems)
    assert_predicate user.repo_subscriptions, :present?

    assert_emails 0 do
      result = BackgroundInactiveEmailJob.perform_now(
        user,
        min_issue_count: 0,
        min_subscriber_count: 0
      )
      assert_equal false, result
    end
  end
end
