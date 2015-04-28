require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  test "issue counter cache" do
    repo = repos(:rails_rails)

    assert_equal 0, repo.issues.count
    assert_equal 0, repo.reload.issues_count

    assert_difference("Repo.find(#{repo.id}).issues_count", 1) do
      issue = repo.issues.new
      issue.title = "Foo Bar"
      issue.url   = "http://schneems.com"
      issue.last_touched_at = 2.days.ago
      issue.state = 'open'
      issue.html_url = "http://schneems.com"
      issue.save
    end

    assert_difference("Repo.find(#{repo.id}).issues_count", -1) do
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

  test "valid_for_user?" do
    user  = users("mockstar")
    issue = repos("rails_rails").issues.new
    issue.stubs(:update_issue!).returns(true)
    issue.stubs(:commenting_users).returns(["foo", "bar"])

    # should be false if a closed issue
    issue.stubs(:closed?).returns(true)
    refute issue.valid_for_user?(user, false), "Issue: #{issue.inspect} expected to be closed"

    # should be true with an open issue with no comments from the current user
    issue.stubs(:closed?).returns(false)
    assert issue.valid_for_user?(user, false)

    # should be false with comments from the current user

    issue.stubs(:commenting_users).returns(["mockstar", "bar"])
    refute issue.valid_for_user?(user, false)
  end

  test "valid_for_user? when has open issue and user skipped with PR" do
    user  = users("mockstar")
    issue = repos("rails_rails").issues.new
    issue.stubs(:commenting_users).returns(["foo", "bar"])

    issue.stubs(:pr_attached?).returns(true)
    user.stubs(:skip_issues_with_pr?).returns(true)
    refute issue.valid_for_user?(user)
  end

  test "valid_for_user? when has open issue and user has not skipped issues with PR" do
    user  = users("mockstar")
    issue = repos("rails_rails").issues.new
    issue.stubs(:commenting_users).returns(["foo", "bar"])
    issue.stubs(:update_issue!).returns(true)

    issue.stubs(:pr_attached?).returns(true)
    user.stubs(:skip_issues_with_pr?).returns(false)
    assert issue.valid_for_user?(user, false), "issue is not valid for given user"
  end

  test "valid_for_user? when issue was created by user and skips own issues" do
    user  = users("mockstar")
    issue = repos("rails_rails").issues.new
    issue.stubs(:commenting_users).returns([])
    issue.stubs(:update_issue!).returns(true)

    # should be false: issue is user's own and chooses to skip
    issue.stubs(:created_by).returns("mockstar")
    user.stubs(:skip_my_own_issues_and_prs?).returns(true)
    refute issue.valid_for_user?(user, false), "issue is not valid for given user"
  end

  test "valid_for_user? when issue was created by user and does not skip own issues" do
    user  = users("mockstar")
    issue = repos("rails_rails").issues.new
    issue.stubs(:commenting_users).returns([])
    issue.stubs(:update_issue!).returns(true)

    # should be true: issue is user's own and chooses not to skip
    issue.stubs(:created_by).returns("mockstar")
    user.stubs(:skip_my_own_issues_and_prs?).returns(false)
    assert issue.valid_for_user?(user, false)
  end

  test 'commenting users' do
    repo = repos("rails_rails")
    issue = repo.issues.new
    issue.repo_name = "rails"
    issue.number = 8404
    issue.save

    commenting_users = []
    VCR.use_cassette('commenting_users_issue') do
      commenting_users = issue.commenting_users
    end
    assert_equal ['Trevoke', 'freegenie', 'pixeltrix', 'steveklabnik'], commenting_users
  end

  test "public_url" do
    repo  = repos("rails_rails")
    issue = repo.issues.new(number: "8404")
    assert_equal "https://github.com/repos/rails/rails/issues/8404", issue.public_url
  end

  test "open_issues" do
    open_issues = []
    repo  = repos("rails_rails")
    repo.issues.new(state: 'closed')

    2.times do
      open_issues << repo.issues.create!(state: 'open')
    end

    assert_equal open_issues, repo.open_issues
  end

end
