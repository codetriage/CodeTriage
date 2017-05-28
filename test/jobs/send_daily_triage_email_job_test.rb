require 'test_helper'

class SendDailyTriageEmailJobTest < ActiveJob::TestCase
  def setup
    @user = User.first
    @job = SendDailyTriageEmailJob.new
  end

  test 'send out daily triage email' do
    def @user.issue_assignments_to_deliver; IssueAssignment.all.limit(1); end

    assert_kind_of Mail::Message, @job.perform(@user)
  end

  test 'does not deliver if no subscriptions' do
    def @user.issue_assignments_to_deliver; []; end

    refute @job.perform(@user)
  end

  test 'does not deliver if email should be skipped' do
    def @user.issue_assignments_to_deliver; IssueAssignment.all.limit(1); end
    def @job.skip_daily_email?(*); true; end

    refute @job.perform(@user)
  end
end
