require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  test "issue counter cache" do
    repo     = Repo.create(:user_name => 'rails', :name => 'rails')

    repo.issues.create(:title           => "Foo Bar",
                       :url             => "http://schneems.com",
                       :last_touched_at => 2.days.ago,
                       :state           => 'open',
                       :html_url        => "http://schneems.com")

    repo.reload
    assert_equal 1, repo.issues_count
    repo.issues.destroy_all
    repo.reload
    assert_equal 0, repo.issues_count
  end

  test "permitted state values" do
    issue = Issue.new

    issue.state = "open"
    assert issue.valid?

    issue.state = "closed"
    assert issue.valid?

    issue.state = "bogus"
    refute issue.valid?
  end
end
