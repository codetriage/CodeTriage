require 'test_helper'

class RepoTest < ActiveSupport::TestCase
  test "normalizing names to lowercase" do
    VCR.use_cassette "create_repo_refinery", record: :once do
      repo = Repo.create user_name: 'Refinery', name: 'Refinerycms'
      assert_equal "refinery", repo.user_name
      assert_equal "refinerycms", repo.name
    end
  end

  test "uniqueness of repo with case insensitivity" do
    VCR.use_cassette "create_repo_refinery", record: :once do
      Repo.create user_name: 'refinery', name: 'refinerycms'
      VCR.use_cassette "create_duplicate_repo_refinery", record: :once do
        duplicate_repo = Repo.create user_name: 'Refinery', name: 'Refinerycms'
        assert_equal ["has already been taken"], duplicate_repo.errors[:name]
      end
    end
  end

  test "update repo info from github" do
    VCR.use_cassette "repo_info" do
      repo = Repo.new user_name: 'refinery', name: 'refinerycms'
      repo.update_from_github
      assert_equal "Ruby", repo.language
      assert_match "CMS", repo.description
    end
  end

  test "update repo info from github error" do
    VCR.use_cassette "repo_info_error", allow_playback_repeats: true do
      repo = Repo.new user_name: 'codetriage', name: 'codetriage'
      assert_raise(GitHubBub::RequestError) { repo.update_from_github }
    end
  end

  test "counts number of subscribers" do
    VCR.use_cassette "create_repo_refinery", record: :once do
      repo = Repo.create user_name: 'Refinery', name: 'Refinerycms'
      repo.users << users(:jroes)
      repo.users << users(:schneems)
      repo.subscriber_count == 2
    end
  end

  test "#all_languages does not contain empty string" do
    VCR.use_cassette "create_repo_refinery", record: :once do
      Repo.create user_name: 'Refinery', name: "RefineryCMS", language: ""
      refute Repo.all_languages.include? ""
    end
  end

  test "repos needing help when user has ruby language" do
    repos = Repo.repos_needing_help_for_user(User.new( favorite_languages: [ "ruby" ])).map(&:path)
    assert_equal [ "bemurphy/issue_triage_sandbox", "sinatra/sinatra" ], repos
  end

  test "repos needing help when user has no languages" do
    repos = Repo.repos_needing_help_for_user(User.new( favorite_languages: [ ])).map(&:path)
    assert_equal [ "bemurphy/issue_triage_sandbox", "sinatra/sinatra" , "andrewrk/groovebasin"], repos
  end

  test "repos needing help when user is null" do
    repos = Repo.repos_needing_help_for_user(nil).map(&:path)
    assert_equal [ "bemurphy/issue_triage_sandbox", "sinatra/sinatra" , "andrewrk/groovebasin"], repos
  end

  test "check existence of repo by its name and user's name" do
    assert Repo.exists_with_name?("bemurphy/issue_triage_sandbox", Repo.all)
    refute Repo.exists_with_name?("prathamesh-sonpatki/issue_triage_sandbox", Repo.all)
  end

  test "#api_issues_path returns issues path with Github api" do
    repo = Repo.new(name: 'codetriage', user_name: 'codetriage')
    assert_equal "repos/codetriage/codetriage/issues", repo.api_issues_path
  end

  test "search_by returns repo by name and user_name" do
    VCR.use_cassette "create_repo_refinery", record: :once do
      repo = Repo.create user_name: 'Refinery', name: 'Refinerycms'
      assert_equal [repo], Repo.search_by('refinerycms', 'refinery')
    end
  end

  test "order by subscribers count" do
    user  = users(:mockstar)
    repo  = repos(:rails_rails)
    user.repo_subscriptions.create(repo: repo, email_limit: 2)
    order_of_repos_by_name        = Repo.order(:name).pluck(:name)
    order_of_repos_by_subscribers = Repo.order_by_subscribers
    refute order_of_repos_by_subscribers.pluck(:name) == order_of_repos_by_name
    assert_equal order_of_repos_by_subscribers.first.name, repo.name
  end
end
