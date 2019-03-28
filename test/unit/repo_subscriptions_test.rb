## quick and dirty tests, need to move logic to Factory or fixture
require 'test_helper'

class RepoSubscriptionsTest < ActiveSupport::TestCase
  test "the get_issue_for_triage for new user" do
    user          = users(:mockstar)
    repo          = repos(:rails_rails)
    repo_sub      = user.repo_subscriptions.new
    repo_sub.repo = repo
    repo_sub.save

    issue                 = repo.issues.new
    issue.title           = "Foo Bar"
    issue.url             = "http://schneems.com"
    issue.last_touched_at = 2.days.ago
    issue.state           = 'open'
    issue.html_url        = "http://schneems.com"
    issue.number          = 1
    issue.save

    Issue.any_instance.stubs(:valid_for_user?).returns(true)
    IssueAssigner.new(user, [repo_sub]).assign!
    assert_equal 1, user.issues.count
  end

  test "the get_issue_for_triage for user with existing issue assignments" do
    user          = users(:empty)
    repo          = repos(:rails_rails)
    repo_sub      = user.repo_subscriptions.new
    repo_sub.repo = repo
    repo_sub.save

    issue                 = repo.issues.new
    issue.title           = "Foo Bar"
    issue.url             = "http://schneems.com"
    issue.last_touched_at = 2.days.ago
    issue.state           = 'open'
    issue.html_url        = "http://schneems.com"
    issue.number          = (repo.issues.last.try(:number) || 0) + 1
    issue.save

    assigned_issue                 = repo.issues.new
    assigned_issue.title           = "Foo Bar"
    assigned_issue.url             = "http://schneems.com"
    assigned_issue.last_touched_at = 2.days.ago
    assigned_issue.state           = 'open'
    assigned_issue.html_url        = "http://schneems.com"
    assigned_issue.number          = (repo.issues.last.try(:number) || 1) + 1
    assigned_issue.save

    repo_sub.issue_assignments.create(issue: assigned_issue)

    Issue.any_instance.stubs(:valid_for_user?).returns(true)
    IssueAssigner.new(user, [repo_sub]).assign!
    assert_equal 2, user.issues.count
  end

  test 'the assign_issue creates an assignment for the user' do
    user          = users(:mockstar)
    repo          = repos(:rails_rails)
    repo_sub      = user.repo_subscriptions.new
    repo_sub.repo = repo
    repo_sub.save

    issue                 = repo.issues.new
    issue.title           = "Foo Bar"
    issue.url             = "http://schneems.com"
    issue.last_touched_at = 2.days.ago
    issue.state           = 'open'
    issue.html_url        = "http://schneems.com"
    issue.number          = 1
    issue.save

    VCR.use_cassette('open_issue') do
      Issue.any_instance.stubs(:valid_for_user?).returns(true)
      IssueAssigner.new(user, [repo_sub]).assign!
      assert_equal 1, user.issue_assignments.count
    end
  end

  test "email_limit allows multiple issues per repo" do
    user  = users(:mockstar)
    repo  = repos(:rails_rails)
    repo.issues.create(title:           "Foo Bar",
                       url:             "http://schneems.com",
                       last_touched_at: 2.days.ago,
                       state:           'open',
                       html_url:        "http://schneems.com",
                       number:          9000)
    repo.issues.create(title:           "Bar Bar",
                       url:             "http://schneems.com",
                       last_touched_at: 2.days.ago,
                       state:           'open',
                       html_url:        "http://schneems.com",
                       number:          9001)
    sub = user.repo_subscriptions.create(repo: repo,
                                         email_limit: 2)
    IssueAssigner.new(user, user.repo_subscriptions).assign!
    assert_equal 2, sub.issue_assignments.count
  end

  test ".subscriptions_for a repo" do
    user  = users(:mockstar)
    repo  = repos(:rails_rails)
    repo2 = repos(:rails_rails)
    repo.issues.create(title:            "Foo Bar",
                       url:              "http://schneems.com",
                       last_touched_at:  2.days.ago,
                       state:            'open',
                       html_url:         "http://schneems.com",
                       number:           9000)

    sub1 = user.repo_subscriptions.create(repo: repo, email_limit: 2)
    user.repo_subscriptions.create(repo: repo2, email_limit: 2)

    assert_equal [sub1], user.repo_subscriptions_for(repo.id)
  end
end
