## quick and dirty tests, need to move logic to Factory or fixture

class RepoSubscriptionsTest < ActiveSupport::TestCase

  test "the get_issue_for_triage for new user" do
    user     = User.create(:email => Time.now.to_f.to_s + "foo@example.com" , :password => Devise.friendly_token[0,20])
    repo     = Repo.create(:user_name => 'rails', :name => 'rails')
    repo_sub = user.repo_subscriptions.create(:repo => repo)

    repo.issues.create(:title           => "Foo Bar",
                       :url             => "http://schneems.com",
                       :last_touched_at => 2.days.ago,
                       :state           => 'open',
                       :html_url        => "http://schneems.com")

    issue = repo_sub.get_issue_for_triage
    assert issue.is_a? Issue
  end


  test "the get_issue_for_triage for user with existing issue assignments" do
    user     = User.create(:email => Time.now.to_f.to_s + "foo@example.com" , :password => Devise.friendly_token[0,20])
    repo     = Repo.create(:user_name => 'rails', :name => 'rails')
    repo_sub = user.repo_subscriptions.create(:repo => repo)

    repo.issues.create(:title           => "Foo Bar",
                       :url             => "http://schneems.com",
                       :last_touched_at => 2.days.ago,
                       :state           => 'open',
                       :html_url        => "http://schneems.com")


    assigned_issue = repo.issues.create( :title           => "Foo Bar",
                                         :url             => "http://schneems.com",
                                         :last_touched_at => 2.days.ago,
                                         :state           => 'open',
                                         :html_url        => "http://schneems.com")

    repo_sub.issue_assignments.create(:issue => assigned_issue)

    issue = repo_sub.get_issue_for_triage
    assert issue.is_a? Issue
  end

end
