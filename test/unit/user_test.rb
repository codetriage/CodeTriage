require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test '#github_url returns github url' do
    assert User.new(github: 'jroes').github_url == 'https://github.com/jroes'
  end

  test 'public scope should only return public users' do
    user           = users(:mockstar)
    repo           = Repo.new
    repo.user_name = 'schneems'
    repo.name      = 'sextant'

    VCR.use_cassette('update_repo_info:schneems/sextant', ) do
      repo.save
    end

    assert_difference("Repo.find(#{repo.id}).users.public_profile.size", 1) do
      repo_sub      = user.repo_subscriptions.new
      repo_sub.repo = repo
      repo_sub.save
    end
  end

  test 'able_to_edit_repo allows the correct rights' do
    u = User.new(github: "bob")
    r = Repo.new(user_name: "bob")
    assert u.able_to_edit_repo?(r)

    r2 = Repo.new(user_name: "neilmiddleton")
    assert !u.able_to_edit_repo?(r2)
  end

  # TODO: move to a job test, this does not test user.rb code
  test 'send out daily triage email' do
    User.any_instance.expects(:send_daily_triage!).once
    user = User.first
    SendDailyTriageEmailJob.new.perform(user.id)
  end

  test 'send_daily_triage!' do
    user  = users(:mockstar)
    repo  = repos(:rails_rails)

    issue = repo.issues.new
    issue.title           = "Foo Bar"
    issue.url             = "http://schneems.com"
    issue.last_touched_at = 2.days.ago
    issue.state           = 'open'
    issue.html_url        = "http://schneems.com"
    issue.number          = (repo.issues.last.try(:number) || 0) + 1
    issue.save

    repo_sub      = user.repo_subscriptions.new
    repo_sub.repo = repo
    repo_sub.save

    assert_difference("User.find(#{user.id}).issue_assignments.where(delivered: true).count", 1) do
      Issue.any_instance.stubs(:valid_for_user?).returns(true)
      user.send_daily_triage!
    end
  end

  test 'User#send_daily_triage! sends the correct # of issues when daily_issue_limit is set' do
    user                   = users(:mockstar)
    user.daily_issue_limit = 1
    repo_names             = [:rails_rails, :node]

    repo_names.each do |name|
      repo                  = repos(name)
      issue                 = repo.issues.new
      issue.title           = "Foo Bar"
      issue.url             = "http://schneems.com"
      issue.last_touched_at = 2.days.ago
      issue.state           = 'open'
      issue.html_url        = "http://schneems.com"
      issue.number          = (repo.issues.last.try(:number) || 0) + 1
      issue.save

      repo_sub      = user.repo_subscriptions.new
      repo_sub.repo = repo
      repo_sub.save
    end

    assert user.repo_subscriptions.present?
    assert EmailDecider.new(user.days_since_last_clicked).now?(user.days_since_last_email)

    assert_difference("User.find(#{user.id}).issues.count", 2) do
      Issue.any_instance.stubs(:valid_for_user?).returns(true)

      user.send_daily_triage!
    end
  end

  test 'valid_email? is true when valid' do
    assert User.new(email: 'richard.schneeman@gmail.com').valid_email?
  end

  test 'valid_email? is false when bad' do
    assert !User.new(email: 'a really bad e-mail address').valid_email?
  end

  test "user favorite_language?" do
    u = User.new(favorite_languages: [ "ruby" ])
    assert u.favorite_language?("ruby")
    assert !u.favorite_language?("java")
  end

  test "user has_favorite_languages?" do
    u = User.new(favorite_languages: [ "ruby" ] )
    assert u.has_favorite_languages?

    u = User.new(favorite_languages: [] )
    assert !u.has_favorite_languages?
  end

  test "account_delete_token should be created on first use" do
    u = User.new
    assert_nil u[:account_delete_token]
    assert_not_equal nil, u.account_delete_token
  end

  test "account_delete_token should be saved unless it is a new record" do
    u = User.new(email: "test@example.com", github: "abcabc123")
    assert_nil u.tap(&:account_delete_token).updated_at

    u.account_delete_token = nil
    u.save

    assert_not_equal u.updated_at, u.tap(&:account_delete_token).updated_at
  end
end
