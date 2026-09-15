# frozen_string_literal: true

require "test_helper"

class GithubFetcher::RepoTest < ActiveSupport::TestCase
  def fetcher(repo)
    GithubFetcher::Repo.new(user_name: repo.user_name, name: repo.name)
  end

  test "quacks like a GithubFetcher::Resource" do
    assert_kind_of GithubFetcher::Resource, GithubFetcher::User.new(token: "asdf")
  end

  test "#as_json returns json" do
    fetcher = fetcher(repos(:scene_hub_v2))
    expected_clone_url = "https://github.com/chrisccerami/scene-hub-v2.git"

    VCR.use_cassette "create_repo_without_issues" do
      assert_equal fetcher.as_json["clone_url"], expected_clone_url, fetcher.as_json
    end
  end

  test "#as_json returns {} when error" do
    GitHubBub.stub(:get, ->(_, _) { raise GitHubBub::RequestError }) do
      fetcher = fetcher(repos(:scene_hub_v2))
      assert_equal fetcher.as_json, {}
      assert_nil fetcher.as_json["clone_url"], fetcher.as_json
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
    GitHubBub.stub(:get, ->(_, _) { raise GitHubBub::RequestError }) do
      fetcher = fetcher(repos(:scene_hub_v2))
      assert_nil fetcher.default_branch
    end
  end

  test "#safe_clone_url? only allows https github.com URLs" do
    assert GithubFetcher::Repo.safe_clone_url?("https://github.com/schneems/get_process_mem.git")

    refute GithubFetcher::Repo.safe_clone_url?("http://github.com/a/b.git")
    refute GithubFetcher::Repo.safe_clone_url?("https://evil.com/a/b.git")
    refute GithubFetcher::Repo.safe_clone_url?("https://github.com.evil.com/a/b.git")
    refute GithubFetcher::Repo.safe_clone_url?("ssh://git@github.com/a/b.git")
    refute GithubFetcher::Repo.safe_clone_url?("file:///etc/passwd")
    refute GithubFetcher::Repo.safe_clone_url?("ext::sh -c id")
    refute GithubFetcher::Repo.safe_clone_url?("--upload-pack=touch /tmp/pwn")
    refute GithubFetcher::Repo.safe_clone_url?(nil)
  end

  test "#clone refuses an unsafe clone_url before running git" do
    fetcher = fetcher(repos(:scene_hub_v2))
    fetcher.stubs(:clone_url).returns("file:///tmp/not-a-real-repo-xyz")

    error = assert_raises(StandardError) { fetcher.clone }
    assert_match(/refus/i, error.message)
  end

  test "#git_clone_argv runs git without a shell and guards option injection" do
    fetcher = fetcher(repos(:scene_hub_v2))
    url = "https://github.com/schneems/get_process_mem.git"

    argv = fetcher.send(:git_clone_argv, url)

    assert_equal "git", argv[0]
    assert_equal "clone", argv[1]
    assert_includes argv, "--depth"
    separator_index = argv.index("--")
    assert separator_index, "expected a -- separator so the URL cannot be parsed as a git option"
    assert_equal url, argv[separator_index + 1]
  end
end
