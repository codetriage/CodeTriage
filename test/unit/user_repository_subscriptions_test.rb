class UserSubscriptionsTest < ActiveSupport::TestCase
  fixtures :users

  test "the users_where_repository_nofitications_sent for time ago for user" do
    setup_repo_subscriptions users(:mockstar,:schneems)
    stale_users = UserRepositorySubscriptions.new.users_where_repository_nofitications_sent(23.hours.ago).to_a
    assert stale_users.size == 2
  end


  test 'the assign_issue creates an assignment for the user' do
    user     = users(:mockstar)
    repo     = repos(:rails_rails)
    repo_sub = user.repo_subscriptions.create(repo: repo)
    repo.issues.create(title:           "Foo Bar",
                       url:             "http://schneems.com",
                       last_touched_at: 2.days.ago,
                       state:           'open',
                       html_url:        "http://schneems.com",
                       number:          1)

    VCR.use_cassette('open_issue') do
      Issue.any_instance.stubs(:valid_for_user?).returns(true)
      repo_sub.assign_issue!(false)
      assert_equal 1, user.issue_assignments.count
    end
  end

  private
    def setup_repo_subscriptions users
      issue = 0
      for user in users
        issue += 1
        repo = repos(:rails_rails)
        user.repo_subscriptions.create repo: repo
        repo.issues.create(title:           "Issue #{issue}",
                           url:             "http://schneems.com",
                           last_touched_at: 2.days.ago,
                           state:           'open',
                           html_url:        "http://schneems.com",
                           number:          issue)
      end
    end
end
