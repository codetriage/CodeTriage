require 'test_helper'

class SendDailyTriageEmailJobTest < ActiveJob::TestCase
  def setup
    @user = User.first
    @job = SendDailyTriageEmailJob.new
  end

  test 'send out daily triage email' do
    def @user.issue_assignments_to_deliver; IssueAssignment.all.limit(1); end
    def @job.before_email_time_of_day?(*); false; end

    assert_kind_of Mail::Message, @job.perform(@user)
  end

  test 'does not deliver if no subscriptions' do
    def @user.issue_assignments_to_deliver; []; end
    def @job.before_email_time_of_day?(*); false; end

    assert_not @job.perform(@user)
  end

  test 'does not deliver if email should be skipped' do
    def @user.issue_assignments_to_deliver; IssueAssignment.all.limit(1); end
    def @job.before_email_time_of_day?(*); false; end
    def @job.skip_daily_email?(*); true; end

    assert_not @job.perform(@user)
  end

  test 'when email_time_of_day not set, it delivers after default time of day' do
    def @user.issue_assignments_to_deliver; IssueAssignment.all.limit(1); end

    Timecop.freeze time_preference_for_today(SendDailyTriageEmailJob::DEFAULT_EMAIL_TIME_OF_DAY) + 1.hour do
      assert_kind_of Mail::Message, @job.perform(@user)
    end
  end

  test 'when email_time_of_day not set, it does not deliver before default time of day' do
    def @user.issue_assignments_to_deliver; IssueAssignment.all.limit(1); end

    Timecop.freeze time_preference_for_today(SendDailyTriageEmailJob::DEFAULT_EMAIL_TIME_OF_DAY) - 1.hour do
      refute @job.perform(@user)
    end
  end

  test 'when email_time_of_day set, it delivers after preferred time of day' do
    def @user.issue_assignments_to_deliver; IssueAssignment.all.limit(1); end
    def @user.email_time_of_day; Time.utc(2000, 1, 1, 04, 0, 0); end

    Timecop.freeze time_preference_for_today(@user.email_time_of_day) + 1.hour do
      assert_kind_of Mail::Message, @job.perform(@user)
    end
  end

  test 'when email_time_of_day set, it does not deliver before preferred time of day' do
    def @user.issue_assignments_to_deliver; IssueAssignment.all.limit(1); end
    def @user.email_time_of_day; Time.utc(2000, 1, 1, 04, 0, 0); end

    Timecop.freeze time_preference_for_today(@user.email_time_of_day) - 1.hour do
      refute @job.perform(@user)
    end
  end

  private

  def time_preference_for_today(time)
    now = Time.current
    Time.utc(now.year, now.month, now.day, time.hour, time.min, time.sec)
  end
end
