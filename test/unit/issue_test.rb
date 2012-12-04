require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  test "issue counter cache" do
    repo     = repos(:rails_rails)

    repo.reload
    assert_equal 0, repo.issues_count

    assert_difference("Repo.where(id: #{repo.id}).first.issues_count", 1) do
      repo.issues.create(:title           => "Foo Bar",
                         :url             => "http://schneems.com",
                         :last_touched_at => 2.days.ago,
                         :state           => 'open',
                         :html_url        => "http://schneems.com")
    end

    assert_difference("Repo.where(id: #{repo.id}).first.issues_count", -1) do
      repo.issues.destroy_all
    end
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
