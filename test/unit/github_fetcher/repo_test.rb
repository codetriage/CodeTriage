require 'test_helper'

class GithubFetcher::RepoTest < ActiveSupport::TestCase
  def fetcher(repo)
    GithubFetcher::Repo.new(user_name: repo.user_name, name: repo.name)
  end

  test "quacks like a GithubFetcher::Resource" do
    assert_kind_of GithubFetcher::Resource, GithubFetcher::User.new(token: 'asdf')
  end

  test "#as_json returns json" do
    fetcher = fetcher(repos(:scene_hub_v2))
    expected_clone_url = "https://github.com/chrisccerami/scene-hub-v2.git"

    VCR.use_cassette "create_repo_without_issues" do
      assert_equal fetcher.as_json['clone_url'], expected_clone_url, fetcher.as_json
    end
  end

  test "#as_json returns {} when error" do
    GitHubBub.stub(:get, -> (_, _) { raise GitHubBub::RequestError }) do
      fetcher = fetcher(repos(:scene_hub_v2))
      assert_equal fetcher.as_json, {}
      assert_nil fetcher.as_json['clone_url'], fetcher.as_json
    end
  end

  test "#default_branch returns the default branch" do
    fetcher = fetcher(repos(:scene_hub_v2))
    expected_default_branch = "master"

    VCR.use_cassette "create_repo_without_issues" do
      assert_equal fetcher.default_branch, expected_default_branch
    end
  end

  test "default_branch returns nil when error" do
    GitHubBub.stub(:get, -> (_, _) { raise GitHubBub::RequestError }) do
      fetcher = fetcher(repos(:scene_hub_v2))
      assert_nil fetcher.default_branch
    end
  end
end
