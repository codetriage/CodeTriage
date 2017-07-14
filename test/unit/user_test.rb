require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test '#github_url returns github url' do
    github_url = User.new(github: 'jroes').github_url
    assert_equal 'https://github.com/jroes', github_url
  end

  test 'public scope should only return public users' do
    user           = users(:mockstar)
    private_user   = users(:jroes)

    # Sanity check for fixture state
    assert_not user.private
    assert private_user.private

    result = User.public_profile

    assert_not_includes result, private_user
    assert_includes result, user
  end

  test 'able_to_edit_repo allows the correct rights' do
    u = User.new(github: "bob")
    r = Repo.new(user_name: "bob")
    assert u.able_to_edit_repo?(r)

    r2 = Repo.new(user_name: "neilmiddleton")
    assert_not u.able_to_edit_repo?(r2)
  end

  test 'valid_email? is true when valid' do
    assert User.new(email: 'richard.schneeman@gmail.com').valid_email?
  end

  test 'valid_email? is false when bad' do
    assert_not User.new(email: 'a really bad e-mail address').valid_email?
  end

  test "user favorite_language?" do
    u = User.new(favorite_languages: [ "ruby" ])
    assert u.favorite_language?("ruby")
    assert_not u.favorite_language?("java")
  end

  test "user has_favorite_languages?" do
    u = User.new(favorite_languages: [ "ruby" ] )
    assert u.has_favorite_languages?

    u = User.new(favorite_languages: [] )
    assert_not u.has_favorite_languages?
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

  test "user assignments to deliver updates assignments" do
    user = users(:mockstar)
    mock = Minitest::Mock.new
    mock.expect(:assign!, true)
    user.instance_variable_set(:@issue_assigner, mock)

    user.issue_assignments_to_deliver

    mock.verify
  end

  test "#own_repos_json" do
    VCR.use_cassette "fetcher_owned_repos_for_user_first_100" do
      assert_equal users(:mockstar).own_repos_json.last['name'], 'writings'
    end
  end

  test "#starred_repos_json" do
    VCR.use_cassette "fetcher_starred_repos_for_user" do
      assert_equal users(:mockstar).starred_repos_json.first['full_name'], 'tscanlin/next-blog'
    end
  end

  test "#subscribed_repos_json" do
    VCR.use_cassette "fetcher_subscribed_repos_for_user" do
      assert_equal users(:mockstar).subscribed_repos_json.first['full_name'], 'thoughtbot/suspenders'
    end
  end

  test "#fetcher" do
    assert users(:mockstar).fetcher.is_a? GithubFetcher::User
  end

  test "#repos_fetcher" do
    assert users(:mockstar).repos_fetcher(GithubFetcher::Repos::OWNED).is_a? GithubFetcher::Repos
  end
end
