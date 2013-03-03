class UserSubscriptionsTest < ActiveSupport::TestCase
  fixtures :users

  test "the users_where_repository_nofitications_sent for time ago for user" do
    setup_repo_subscriptions users(:mockstar,:schneems)
    stale_users = UserRepositorySubscriptions.new.users_where_repository_nofitications_sent(23.hours.ago).to_a
    assert_equal 2, stale_users.size
  end

  private
    def setup_repo_subscriptions users
      issue = 0
      for user in users
        issue += 1
        for repo in repos(:rails_rails,:issue_triage_sandbox)
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
end
