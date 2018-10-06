# frozen_string_literal: true

require 'test_helper'

class BackgroundInactiveEmailJobTest < ActiveJob::TestCase
  test 'That we do not poke the user when he is subscribed to a repo' do
    user_with_subscriptions = repo_subscriptions(:schneems_to_triage).user

    user_poked = BackgroundInactiveEmailJob.perform_now(user_with_subscriptions)

    assert_not user_poked
  end

  test 'We poke the user when he is not subscribed to a repo' do
    user_without_subscriptions = users(:empty)

    assert_enqueued_with(job: ActionMailer::DeliveryJob, queue: 'mailers') do
      BackgroundInactiveEmailJob.perform_now(user_without_subscriptions)
    end
  end
end
