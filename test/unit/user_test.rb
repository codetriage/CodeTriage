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
    assert_equal nil, u[:account_delete_token]
    assert_not_equal nil, u.account_delete_token
  end

  test "account_delete_token should be saved unless it is a new record" do
    u = User.new(email: "test@example.com", github: "abcabc123")
    assert_equal nil, u.tap(&:account_delete_token).updated_at

    u.account_delete_token = nil
    u.save

    assert_not_equal u.updated_at, u.tap(&:account_delete_token).updated_at
  end

  test "user assignments to deliver updates assignments" do
    user = User.first
    mock = Minitest::Mock.new
    mock.expect(:assign!, true)
    user.instance_variable_set(:@issue_assigner, mock)

    user.issue_assignments_to_deliver

    mock.verify
  end
end
