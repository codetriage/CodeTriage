# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  include ActiveJob::TestHelper::TestQueueAdapter
  def time_preference_for_today(time)
    now = Time.current
    Time.utc(now.year, now.month, now.day, time.hour, time.min, time.sec)
  end

  def send_email(user)
    assert_performed_with(job: ActionMailer::DeliveryJob, queue: "mailers") do
      Time.stub(:now, time_preference_for_today(SendDailyTriageEmailJob::DEFAULT_EMAIL_TIME_OF_DAY) + 1.hour) do
        SendDailyTriageEmailJob.new.perform(user)
      end
    end
  end

  test "sends issues" do
    user = users(:schneems)
    send_email(user)
    triage_email = ActionMailer::Base.deliveries.last
    triage_email_text = triage_email.text_part.to_s
    assert_equal 2, triage_email.parts.size
    assert_equal "multipart/alternative", triage_email.mime_type

    assert_match /Help Triage \d+ Open Source Issue/, triage_email.subject

    # Repo groups
    assert_match /## bemurphy\/issue_triage_sandbox/, triage_email_text

    # Issue number one
    assert_match /bemurphy\/issue_triage_sandbox#1/, triage_email_text
  end

  test "sends docs" do
    user = users(:bar_user)
    send_email(user)
    triage_email = ActionMailer::Base.deliveries.last
    triage_email_text = triage_email.text_part.to_s
    assert_equal 2, triage_email.parts.size
    assert_equal "multipart/alternative", triage_email.mime_type

    assert_match /Help Triage 1 Open Source Doc/, triage_email.subject

    assert_match /### Docs/, triage_email_text
  end
end
