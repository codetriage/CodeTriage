## quick and dirty tests, need to move logic to Factory or fixture
require 'test_helper'

class RepoSubscriptionsTest < ActiveSupport::TestCase
  fixtures :users

  test "the get_issue_for_triage for new user" do
    user     = users(:mockstar)
    repo     = repos(:rails_rails)
    repo_sub = user.repo_subscriptions.create(:repo => repo)

    repo.issues.create(title:           "Foo Bar",
                       url:             "http://schneems.com",
                       last_touched_at: 2.days.ago,
                       state:           'open',
                       html_url:        "http://schneems.com",
                       number:          1)
    VCR.use_cassette('open_issue') do
      Issue.any_instance.stubs(:valid_for_user?).returns(true)
      issue = repo_sub.get_issue_for_triage
      assert issue.is_a? Issue
    end
  end


  test "the get_issue_for_triage for user with existing issue assignments" do
    user     = users(:mockstar)
    repo     = repos(:rails_rails)
    repo_sub = user.repo_subscriptions.create(:repo => repo)

    repo.issues.create(title:           "Foo Bar",
                       url:             "http://schneems.com",
                       last_touched_at: 2.days.ago,
                       state:           'open',
                       html_url:        "http://schneems.com",
                       number:          1)


    assigned_issue = repo.issues.create(title:           "Foo Bar",
                                        url:             "http://schneems.com",
                                        last_touched_at: 2.days.ago,
                                        state:           'open',
                                        html_url:        "http://schneems.com",
                                        number:          2)

    repo_sub.issue_assignments.create(:issue => assigned_issue)
    VCR.use_cassette('open_issue') do
      Issue.any_instance.stubs(:valid_for_user?).returns(true)
      issue = repo_sub.get_issue_for_triage
      assert issue.is_a? Issue
    end
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
      repo_sub.assign_issue!
      assert_equal 1, user.issue_assignments.count
    end
  end

  test "email_limit allows multiple issues per repo" do
    user  = users(:mockstar)
    repo  = repos(:rails_rails)
    issue = repo.issues.create(:title           => "Foo Bar",
                               :url             => "http://schneems.com",
                               :last_touched_at => 2.days.ago,
                               :state           => 'open',
                               :html_url        => "http://schneems.com",
                               :number          => 9000)
    sub = user.repo_subscriptions.create(repo:        repo,
                                   email_limit: 2)

    RepoSubscription.any_instance.expects(:assign_issue!).twice
    sub.assign_multi_issues!

  end
end
