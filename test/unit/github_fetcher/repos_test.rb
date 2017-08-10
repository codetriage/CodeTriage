require 'test_helper'

class GithubFetcher::ReposTest < ActiveSupport::TestCase
  def fetcher(kind, options={})
    GithubFetcher::Repos.new(
      {
        token: OmniAuth.config.mock_auth[:github][:credentials][:token],
        kind: kind,
      }.merge(options)
    )
  end

  test "quacks like a GithubFetcher::Resource" do
    assert_kind_of GithubFetcher::Resource, GithubFetcher::User.new(token: 'asdf')
  end

  test "#as_json returns json" do
    fetcher = fetcher(GithubFetcher::Repos::STARRED)

    expected_first_repo_name = "tscanlin/next-blog"

    VCR.use_cassette "fetcher_starred_repos_for_user" do
      assert_equal fetcher.as_json.first['full_name'],
                   expected_first_repo_name,
                   fetcher.as_json.first
      assert_equal fetcher.as_json.count, 30, fetcher.as_json.count
    end
  end

  test "raises error when kind is invalid" do
    assert_raise(TypeError) { GithubFetcher::Repos.new('foo') }
  end

  test "can set response size" do
    fetcher = fetcher(GithubFetcher::Repos::STARRED, per_page: 60)

    VCR.use_cassette "fetcher_more_starred_repos_for_user" do
      assert_equal fetcher.as_json.count, 60, fetcher.as_json.count
    end
  end

  test "can get owned repos" do
    fetcher = fetcher(GithubFetcher::Repos::OWNED)

    expected_last_repo_name = 'writings'

    VCR.use_cassette "fetcher_owned_repos_for_user" do
      assert_equal fetcher.as_json.last['name'], expected_last_repo_name
    end
  end

  test "can get starred repos" do
    fetcher = fetcher(GithubFetcher::Repos::STARRED)
    expected_first_repo_name = "tscanlin/next-blog"
    VCR.use_cassette "fetcher_starred_repos_for_user" do
      assert_equal fetcher.as_json.first['full_name'], expected_first_repo_name
    end
  end

  test "can get subscribed repos" do
    fetcher = fetcher(GithubFetcher::Repos::SUBSCRIBED)
    expected_first_repo_name = "thoughtbot/suspenders"
    VCR.use_cassette "fetcher_subscribed_repos_for_user" do
      assert_equal fetcher.as_json.first['full_name'], expected_first_repo_name
    end
  end

  test "#as_json returns {} when error" do
    GitHubBub.stub(:get, -> (_, _) { raise GitHubBub::RequestError }) do
      fetcher = fetcher('starred')
      assert_equal fetcher.as_json, {}
    end
  end
end
