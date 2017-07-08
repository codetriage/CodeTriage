require 'test_helper'

class PopulateIssuesTest < ActiveSupport::TestCase
  test ".call kicks off populate_multi_issues!" do
    PopulateIssues.any_instance.expects(:populate_multi_issues!)
    PopulateIssues.(repos(:rails_rails))
  end

  test "#populate_multi_issues continues until populate_issues is false" do
    called = 0
    service = PopulateIssues.new(repos(:rails_rails), 'open')
    service.stub(:populate_issues, -> (page) { called += 1; page.in? [1,2] }) do
      service.populate_multi_issues!
    end
    assert_equal called, 3
  end

  test "#populate_multi_issues creates issues" do
    repo = repos(:issue_triage_sandbox)
    repo.issues.where(state: 'open').destroy_all
    VCR.use_cassette "issue_triage_sandbox_fetch_issues" do
      assert_difference("Issue.count", 1) do
        PopulateIssues.(repo)
      end
    end
  end

  test "#populate_multi_issues stores error info when fails" do
  end
end
