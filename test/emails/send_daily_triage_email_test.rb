require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  include ActiveJob::TestHelper::TestQueueAdapter

  test "sends issues" do
    user = users(:schneems)

    assert_performed_with(job: ActionMailer::DeliveryJob, queue: "mailers") do
      SendDailyTriageEmailJob.new.perform(user)
    end

    triage_email = ActionMailer::Base.deliveries.last
    triage_email_text = triage_email.text_part.to_s

    assert_match /Help Triage 2 Open Source Issues/, triage_email.subject

    # Repo groups
    assert_match /## rails\/rails/,                   triage_email_text
    assert_match /## bemurphy\/issue_triage_sandbox/, triage_email_text

    # Issue number one
    assert_match /rails\/rails#1/,                    triage_email_text
  end

  test "sends docs" do
    user = users(:bar_user)

    assert_performed_with(job: ActionMailer::DeliveryJob, queue: "mailers") do
      SendDailyTriageEmailJob.new.perform(user)
    end

    triage_email = ActionMailer::Base.deliveries.last
    triage_email_text = triage_email.text_part.to_s

    assert_match /Help Triage 1 Open Source Doc/, triage_email.subject

    assert_match /### Docs/, triage_email_text
  end
end
