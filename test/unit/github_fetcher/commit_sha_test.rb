require 'test_helper'

class GithubFetcher::CommitShaTest < ActiveSupport::TestCase
  def fetcher(repo)
    GithubFetcher::CommitSha.new(
      user_name: repo.user_name,
      name: repo.name,
      default_branch: 'master'
    )
  end

  test "quacks like a GithubFetcher::Resource" do
    fetcher = fetcher(repos(:issue_triage_sandbox))
    GithubFetcher::Resource.instance_methods(false).each do |method|
      assert fetcher.respond_to? method, "Failed to respond_to? #{method}"
    end
    GithubFetcher::Resource.private_instance_methods(false).each do |method|
      assert fetcher.respond_to? method, "Failed to respond_to? #{method}"
    end
  end

  test "#as_json returns json" do
    fetcher = fetcher(repos(:scene_hub_v2))

    VCR.use_cassette "fetcher_commit_sha" do
      assert_equal fetcher.as_json, {}, fetcher.as_json
    end
  end

  test "#as_json returns {} when error" do
    GitHubBub.stub(:get, -> (_, _) { raise GitHubBub::RequestError }) do
      fetcher = fetcher(repos(:scene_hub_v2))
      assert_equal fetcher.as_json, {}
    end
  end

  test "#commit_sha returns the sha branch" do
    fetcher = fetcher(repos(:scene_hub_v2))
    expected_sha = ""

    VCR.use_cassette "fetcher_commit_sha" do
      assert_equal fetcher.commit_sha, expected_sha
    end
  end

  test "#commit_sha returns nil when error" do
    GitHubBub.stub(:get, -> (_, _) { raise GitHubBub::RequestError }) do
      fetcher = fetcher(repos(:scene_hub_v2))
      assert_nil fetcher.commit_sha
    end
  end
end
