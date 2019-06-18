# frozen_string_literal: true

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
    assert_kind_of GithubFetcher::Resource, GithubFetcher::User.new(token: 'asdf')
  end

  test "#as_json returns json" do
    fetcher = fetcher(repos(:scene_hub_v2))
    commit_message = "Fixed geojson method in band model"

    VCR.use_cassette "fetcher_commit_sha" do
      assert_equal fetcher.as_json['commit']['message'], commit_message, fetcher.as_json
    end
  end

  test "#as_json returns {} when error" do
    GitHubBub.stub(:get, ->(_, _) { raise GitHubBub::RequestError }) do
      fetcher = fetcher(repos(:scene_hub_v2))
      assert_equal fetcher.as_json, {}
    end
  end

  test "#commit_sha returns the sha branch" do
    fetcher = fetcher(repos(:scene_hub_v2))
    expected_sha = "12dd603a7ea29fe2cb4ec7394d48c6efd4cad653"

    VCR.use_cassette "fetcher_commit_sha" do
      assert_equal fetcher.commit_sha, expected_sha
    end
  end

  test "#commit_sha returns nil when error" do
    GitHubBub.stub(:get, ->(_, _) { raise GitHubBub::RequestError }) do
      fetcher = fetcher(repos(:scene_hub_v2))
      assert_nil fetcher.commit_sha
    end
  end
end
