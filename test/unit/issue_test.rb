require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  test "issue counter cache" do
    repo     = repos(:rails_rails)

    assert_equal 0, repo.issues.count
    assert_equal 0, repo.reload.issues_count

    assert_difference("Repo.find(#{repo.id}).issues_count", 1) do
      repo.issues.create(:title           => "Foo Bar",
                         :url             => "http://schneems.com",
                         :last_touched_at => 2.days.ago,
                         :state           => 'open',
                         :html_url        => "http://schneems.com")
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
      assert !@issue.valid_for_user?(@user)
    end

    should 'be true with an open issue uncommented' do
      @issue.stubs(:closed?).returns(false)
      @issue.stubs(:commenting_users).returns(["foo", "bar"])
      assert @issue.valid_for_user?(@user)
    end

    should 'be false with a commented open issue' do
      @issue.stubs(:closed?).returns(false)
      @issue.stubs(:commenting_users).returns(["mockstar", "bar"])
      assert !@issue.valid_for_user?(@user)
    end
  end

  test '#commenting users' do
    repo = repos("rails_rails")
    issue = repo.issues.new(repo_name: "rails", number: 8404)

    commenting_users = []
    VCR.use_cassette('commenting_users_issue') do
      commenting_users = issue.commenting_users
    end
    assert_equal ['Trevoke', 'freegenie', 'pixeltrix', 'steveklabnik'], commenting_users
  end

end
