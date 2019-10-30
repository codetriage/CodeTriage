# frozen_string_literal: true

require 'test_helper'

class PopulateIssuesJobTest < ActiveJob::TestCase
  test "#perform kicks off populate_multi_issues!" do
    PopulateIssuesJob.any_instance.expects(:populate_multi_issues!)
    PopulateIssuesJob.perform_now(repos(:rails_rails))
  end

  test "Works when there's no issues" do
    stub_request(:any, "https://api.github.com/repos/bemurphy/issue_triage_sandbox/issues?direction=desc&page=1&sort=comments&state=open")
      .to_return({ body: [].to_json, status: 200 })

    repo = repos(:issue_triage_sandbox)

    PopulateIssuesJob.perform_now(repo)
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
