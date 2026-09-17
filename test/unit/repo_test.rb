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

  test "#populate_docs! removes the working directory it cloned" do
    repo = repos(:get_process_mem)
    cloned_dir = nil

    repo.fetcher.define_singleton_method(:clone) do
      dir = send(:dir)
      cloned_dir = dir
      FileUtils.mkdir_p(File.join(dir, "lib"))
      File.write(File.join(dir, "lib", "thing.rb"), "class Thing\n  def hello\n  end\nend\n")
      dir
    end

    repo.populate_docs!(commit_sha: "abc123", has_subscribers: true)

    refute_nil cloned_dir
    refute Dir.exist?(cloned_dir),
      "expected populate_docs! to clean up the temp dir it cloned"
  end

  test "#populate_docs! does not delete a caller-provided location" do
    repo = repos(:get_process_mem)
    location = Dir.mktmpdir
    FileUtils.mkdir_p(File.join(location, "lib"))
    File.write(File.join(location, "lib", "thing.rb"), "class Thing\n  def hello\n  end\nend\n")

    repo.populate_docs!(commit_sha: "abc123", location: location, has_subscribers: true)

    assert Dir.exist?(location), "a caller-provided location must not be deleted"
  ensure
    FileUtils.remove_entry(location) if location && Dir.exist?(location)
  end

  test "docs_subscriber_count counts only active doc subscriptions" do
    repo = repos(:no_subscribers)
    sub = RepoSubscription.create!(repo: repo, user: users(:schneems), write_limit: 1)
    sub.update_column(:docs_last_click_at, Time.current)

    repo.force_issues_count_sync!
    assert_equal 1, repo.reload.docs_subscriber_count

    sub.update_column(:docs_last_click_at, (RepoSubscription::DOC_ACTIVITY_WINDOW + 1.day).ago)
    repo.force_issues_count_sync!
    assert_equal 0, repo.reload.docs_subscriber_count
  end

  test "has_doc_subscribers? is true only when a read/write subscription exists" do
    assert repos(:issue_triage_sandbox).has_doc_subscribers? # write_doc_only
    refute repos(:no_subscribers).has_doc_subscribers?
  end

  test "has_active_doc_subscribers? requires a recent doc click" do
    repo = repos(:issue_triage_sandbox)
    refute repo.has_active_doc_subscribers? # write_doc_only has nil docs_last_click_at

    repo_subscriptions(:write_doc_only).update_column(:docs_last_click_at, Time.current)
    assert repo.has_active_doc_subscribers?
  end

  test "doc_opt_in_open_to? gates fresh accounts unless the repo is already active" do
    repo = repos(:no_subscribers)
    old_user = users(:schneems) # created 2012
    new_user = users(:mockstar)
    new_user.update_column(:created_at, Time.current)

    assert repo.doc_opt_in_open_to?(old_user)
    assert repo.doc_opt_in_open_to?(nil) # logged-out visitor sees the CTA
    refute repo.doc_opt_in_open_to?(new_user)

    active = RepoSubscription.create!(repo: repo, user: old_user, write_limit: 1)
    active.update_column(:docs_last_click_at, Time.current)
    assert repo.doc_opt_in_open_to?(new_user)
  end

  test "populate_docs! short-circuits when doc generation is disabled" do
    ENV["DISABLE_DOC_GENERATION"] = "1"
    repo = repos(:issue_triage_sandbox)

    # Pass commit_sha so the default-arg fetcher (network) is never evaluated;
    # the kill-switch guard is the first line of the method body.
    assert_equal "Skipped, doc generation disabled", repo.populate_docs!(commit_sha: "abc123")
  ensure
    ENV.delete("DISABLE_DOC_GENERATION")
  end
end
