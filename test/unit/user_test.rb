require 'test_helper'

class UserTest < ActiveSupport::TestCase

  setup do
    Resque.inline = true
  end

  teardown do
    Resque.inline = false
  end

  test '#github_url returns github url' do
    assert User.new(:github => 'jroes').github_url == 'https://github.com/jroes'
  end

  test 'public scope should only return public users' do
    assert_equal 2, User.public.size

    user     = users(:mockstar)
    repo     = Repo.create(:user_name => 'schneems', :name => 'sextant')
    repo_sub = user.repo_subscriptions.create(:repo => repo)

    assert_equal 1, repo.users.public.size
  end

  test 'able_to_edit_repo allows the correct rights' do
    u = User.new(:github => "bob")
    r = Repo.new(:user_name => "bob")
    assert u.able_to_edit_repo?(r)
    r2 = Repo.new(:user_name => "neilmiddleton")
    assert !u.able_to_edit_repo?(r2)
  end

  test 'send out daily triage email' do
    User.any_instance.expects(:send_daily_triage_email!).at_least_once
    User.queue_triage_emails!
  end

  test 'User#send_daily_triage!' do
    user  = users(:mockstar)
    repo  = repos(:rails_rails)
    issue = repo.issues.create(:title           => "Foo Bar",
                               :url             => "http://schneems.com",
                               :last_touched_at => 2.days.ago,
                               :state           => 'open',
                               :html_url        => "http://schneems.com",
                               :number          => 9000)
    user.repo_subscriptions.create(repo: repo)
    assert_difference("User.find(#{user.id}).issues.count", 1) do
      Issue.any_instance.stubs(:valid_for_user?).returns(true)
      user.send_daily_triage!
    end
  end

  test 'valid_email? is true when valid' do
    assert User.new(:email => 'richard.schneeman@gmail.com').valid_email?
  end

  test 'valid_email? is false when bad' do
    assert !User.new(:email => 'a really bad e-mail address').valid_email?
  end
end
