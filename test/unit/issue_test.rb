require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  test "issue counter cache" do
    repo     = repos(:rails_rails)

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

  context '#valid_for_user?' do
    setup do
      @user = users("mockstar")
      repo = repos("rails_rails")
      @issue = repo.issues.new
      @issue.stubs(:update_issue!).returns(true)
    end

    should 'be false with a closed issue' do
      @issue.stubs(:closed?).returns(true)
      refute @issue.valid_for_user?(@user)
    end

    should 'be true with an open issue with no comments from the current user' do
      @issue.stubs(:closed?).returns(false)
      @issue.stubs(:commenting_users).returns(["foo", "bar"])
      assert @issue.valid_for_user?(@user)
    end

    should 'be false with an open issue with comments from the current user' do
      @issue.stubs(:closed?).returns(false)
      @issue.stubs(:commenting_users).returns(["mockstar", "bar"])
      refute @issue.valid_for_user?(@user)
    end

    should 'be false with an open issue with attached PR if current user has skipped issues with PR' do
      @issue.stubs(:pr_attached?).returns(true)
      @user.stubs(:skip_issues_with_pr?).returns(true)
      refute @issue.valid_for_user?(@user)
    end

    should 'be true with an open issue with attached PR if current user has not skipped issues with PR' do
      @issue.stubs(:pr_attached?).returns(true)
      @user.stubs(:skip_issues_with_pr?).returns(false)
      assert @issue.valid_for_user?(@user)
    end
  end

  test '#commenting users' do
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

  test "#public_url" do
    repo  = repos("rails_rails")
    issue = repo.issues.new(number: "8404")
    assert_equal "https://github.com/repos/rails/rails/issues/8404", issue.public_url
  end
end
