# frozen_string_literal: true

require "test_helper"

class SendDailyTriageEmailJobTest < ActiveJob::TestCase
  def setup
    @user = User.first
    @job = SendDailyTriageEmailJob.new
  end

  test "send out daily triage email" do
    def @user.issue_assignments_to_deliver
      IssueAssignment.all.limit(1)
    end

    def @job.before_email_time_of_day?(*)
      false
    end

    # {:job=>ActionMailer::DeliveryJob, :args=>["UserMailer", "send_daily_triage", "deliver_now", {"user_id"=>110871456, "assignment_ids"=>[980190962], "write_doc_ids"=>[], "read_doc_ids"=>[], "_aj_symbol_keys"=>["user_id", "assignment_ids", "write_doc_ids", "read_doc_ids"]}], :queue=>"mailers"}.
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob, queue: "default") do
      @job.perform(@user)
    end
  end

  test "does not deliver if no subscriptions" do
    def @user.issue_assignments_to_deliver
      []
    end

    def @job.before_email_time_of_day?(*)
      false
    end

    assert_not @job.perform(@user)
  end

  test "does not deliver if email should be skipped" do
    def @user.issue_assignments_to_deliver
      IssueAssignment.all.limit(1)
    end

    def @job.skip_daily_email?(*)
      true
    end

    assert_not @job.perform(@user)
  end

  test "when email_time_of_day not set, it delivers after default time of day" do
    def @user.issue_assignments_to_deliver
      IssueAssignment.all.limit(1)
    end

    Time.stub(:now, time_preference_for_today(SendDailyTriageEmailJob::DEFAULT_EMAIL_TIME_OF_DAY) + 1.hour) do
      assert_enqueued_jobs 1 do
        @job.perform(@user)
      end
    end
  end

  test "when email_time_of_day not set, it does not deliver before default time of day" do
    def @user.issue_assignments_to_deliver
      IssueAssignment.all.limit(1)
    end

    Time.stub(:now, time_preference_for_today(SendDailyTriageEmailJob::DEFAULT_EMAIL_TIME_OF_DAY) - 1.hour) do
      assert_not @job.perform(@user)
    end
  end

  test "when email_time_of_day set, it delivers at preferred time of day" do
    def @user.issue_assignments_to_deliver
      IssueAssignment.all.limit(1)
    end

    def @user.email_time_of_day
      Time.utc(2000, 1, 1, 0o4, 0, 0)
    end

    Time.stub(:now, time_preference_for_today(@user.email_time_of_day)) do
      assert_enqueued_jobs 1 do
        @job.perform(@user)
      end
    end
  end

  test "when email_time_of_day set, it does not deliver before preferred time of day" do
    def @user.issue_assignments_to_deliver
      IssueAssignment.all.limit(1)
    end

    def @user.email_time_of_day
      Time.utc(2000, 1, 1, 0o4, 0, 0)
    end

    Time.stub(:now, time_preference_for_today(@user.email_time_of_day) - 1.hour) do
      assert_not @job.perform(@user)
    end
  end

  test "when run multiple times a day, it does not deliver again" do
    def @user.issue_assignments_to_deliver
      IssueAssignment.all.limit(1)
    end

    def @user.email_time_of_day
      Time.utc(2000, 1, 1, 0o4, 0, 0)
    end

    Time.stub(:now, time_preference_for_today(@user.email_time_of_day) + 1.hour) do
      @job.perform(@user)
      assert_not @job.perform(@user)
    end
  end

  test "when preference changed, sends at preferred time next day" do
    def @user.issue_assignments_to_deliver
      IssueAssignment.all.limit(1)
    end

    def @user.email_time_of_day
      Time.utc(2000, 1, 1, 18, 0, 0)
    end

    Time.stub(:now, time_preference_for_today(@user.email_time_of_day)) do
      assert_enqueued_jobs 1 do
        assert @job.perform(@user)
      end
    end

    def @user.email_time_of_day
      Time.utc(2000, 1, 1, 0o4, 0, 0)
    end

    Time.stub(:now, time_preference_for_today(@user.email_time_of_day) + 1.day) do
      assert_enqueued_jobs 1 do
        assert @job.perform(@user)
      end
    end
  end

  private

  def time_preference_for_today(time)
    now = Time.current
    Time.utc(now.year, now.month, now.day, time.hour, time.min, time.sec)
  end
end
