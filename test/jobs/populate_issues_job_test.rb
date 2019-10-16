# frozen_string_literal: true

require 'test_helper'

class PopulateIssuesJobTest < ActiveJob::TestCase
  test "#perform kicks off populate_multi_issues!" do
    PopulateIssuesJob.any_instance.expects(:populate_multi_issues!)
    PopulateIssuesJob.perform_now(repos(:rails_rails))
  end

  test "#populate_multi_issues continues until populate_issues is false" do
    called = 0
    job = PopulateIssuesJob.new
    job.instance_variable_set(:@repo, repos(:rails_rails))
    job.instance_variable_set(:@state, 'open')
    job.stub(:populate_issues, ->(page) { called += 1; page.in? [1, 2] }) do
      job.populate_multi_issues!
    end
    assert_equal called, 3
  end

  test "#populate_multi_issues creates issues" do
    repo = repos(:issue_triage_sandbox)
    repo.issues.where(state: 'open').delete_all
    VCR.use_cassette "issue_triage_sandbox_fetch_issues" do
      assert_difference("Issue.count", 1) do
        PopulateIssuesJob.perform_now(repo)
      end
    end
  end

  test "#populate_multi_issues stores error info when fails" do
    repo = repos(:issue_triage_sandbox)
    def repo.issues_fetcher
      fetcher = OpenStruct.new(error?: true, error_message: 'something went wrong', page: 1)
      def fetcher.call(*args); end
      fetcher
    end

    PopulateIssuesJob.perform_now(repo)
    assert_equal repo.github_error_msg, 'something went wrong'
  end

  test "updates existing issues" do
    repo = repos(:issue_triage_sandbox)

    VCR.use_cassette "issue_triage_sandbox_fetch_issues" do
      assert_difference("Issue.count", 0) do
        PopulateIssuesJob.perform_now(repo)
      end
    end
  end
end
