# frozen_string_literal: true

require "test_helper"

class RepoTest < ActiveSupport::TestCase
  test "normalizing names to lowercase" do
    VCR.use_cassette "create_repo_refinery", record: :once do
      repo = Repo.create user_name: "Refinery", name: "Refinerycms"
      assert_equal "refinery", repo.user_name
      assert_equal "refinerycms", repo.name
    end
  end

  test "uniqueness of repo with case insensitivity" do
    VCR.use_cassette "create_repo_refinery", record: :once do
      Repo.create user_name: "refinery", name: "refinerycms"
      VCR.use_cassette "create_duplicate_repo_refinery", record: :once do
        assert_raises(ActiveRecord::RecordNotUnique) {
          Repo.create user_name: "Refinery", name: "Refinerycms"
        }
      end
    end
  end

  test "update repo info from github" do
    VCR.use_cassette "repo_info" do
      repo = Repo.new user_name: "refinery", name: "refinerycms"
      repo.update_from_github
      assert_equal "Ruby", repo.language
      assert_match "CMS", repo.description
    end
  end

  test "github url validation attempts to use issue_fetcher" do
    repo = Repo.new user_name: "codetriage", name: "codetriage"
    repo.stub(:issues_fetcher, -> { OpenStruct.new(error?: true, api_path: "123") }) do
      repo.send(:github_url_exists)
      assert_equal "cannot reach api.github.com/123 perhaps github is down, or you mistyped something?",
        repo.errors.messages[:expiration_date].first
    end
  end

  test "counts number of subscribers" do
    VCR.use_cassette "create_repo_refinery", record: :once do
      repo = Repo.create user_name: "Refinery", name: "Refinerycms"
      repo.users << users(:jroes)
      repo.users << users(:schneems)
      repo.subscribers_count == 2
    end
  end

  test "#all_languages does not contain empty string" do
    VCR.use_cassette "create_repo_refinery", record: :once do
      Repo.create user_name: "Refinery", name: "RefineryCMS", language: ""
      assert_not Repo.all_languages.include? ""
    end
  end

  # CI can switch the ordering of these repos, but we dont care about ordering,
  # so use set intersection
  test "repos needing help when user has ruby language" do
    repos = Repo.repos_needing_help_for_user(User.new(favorite_languages: ["ruby"])).map(&:full_name)
    assert_operator ["bemurphy/issue_triage_sandbox", "sinatra/sinatra"], "&", repos
  end

  test "repos needing help when user has no languages" do
    repos = Repo.repos_needing_help_for_user(User.new(favorite_languages: [])).map(&:full_name)
    assert_operator ["bemurphy/issue_triage_sandbox", "sinatra/sinatra", "andrewrk/groovebasin"], "&", repos
  end

  test "repos needing help when user is null" do
    repos = Repo.repos_needing_help_for_user(nil).map(&:full_name)
    assert_operator ["bemurphy/issue_triage_sandbox", "sinatra/sinatra", "andrewrk/groovebasin"], "&", repos
  end

  test "check existence of repo by its name and user's name" do
    assert Repo.exists_with_name?("bemurphy/issue_triage_sandbox")
    assert_not Repo.exists_with_name?("prathamesh-sonpatki/issue_triage_sandbox")
  end

  test "issues_fetcher.api_path (private method) returns issues path with Github api" do
    repo = Repo.new(name: "codetriage", user_name: "codetriage")
    assert_equal "repos/codetriage/codetriage/issues", repo.issues_fetcher.send(:api_path)
  end

  test "search_by returns repo by name and user_name" do
    VCR.use_cassette "create_repo_refinery", record: :once do
      repo = Repo.create user_name: "Refinery", name: "Refinerycms"
      assert_equal [repo], Repo.search_by("refinerycms", "refinery")
    end
  end

  test "#fetcher" do
    assert repos(:rails_rails).fetcher.is_a? GithubFetcher::Repo
  end

  test "#issues_fetcher" do
    assert repos(:rails_rails).issues_fetcher.is_a? GithubFetcher::Issues
  end

  test "#commit_sha_fetcher" do
    VCR.use_cassette "create_repo_without_issues" do
      assert repos(:scene_hub_v2).commit_sha_fetcher.is_a? GithubFetcher::CommitSha
    end
  end

  test ".without_user_subscriptions" do
    user = users(:schneems)
    subscribed_repo = user.repo_subscriptions.first
    unsubscribed_repo = repos(:no_subscribers)

    repos = Repo.without_user_subscriptions(user.id).to_a
    assert_not repos.include?(subscribed_repo)
    assert repos.include?(unsubscribed_repo)
  end
end
