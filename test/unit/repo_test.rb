require 'test_helper'

class RepoTest < ActiveSupport::TestCase
  test "normalizing names to lowercase" do
    repo = Repo.create user_name: 'Refinery', name: 'Refinerycms'
    assert_equal "refinery", repo.user_name
    assert_equal "refinerycms", repo.name
  end

  test "uniqueness of repo with case insensitivity" do
    Repo.create user_name: 'refinery', name: 'refinerycms'
    duplicate_repo = Repo.create :user_name => 'Refinery', :name => 'Refinerycms'
    assert_equal ["has already been taken"], duplicate_repo.errors[:name]
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
    repo = Repo.create :user_name => 'Refinery', :name => 'Refinerycms'
    repo.users << users(:jroes)
    repo.users << users(:schneems)
    repo.subscriber_count == 2
  end

  test "#all_languages contains no empty results" do
    repo = Repo.create :user_name => 'Refinery', :name => "RefineryCMS", :language => ""
    refute Repo.all_languages.include? ""
  end

  test "repos needing help when user has ruby language" do
    repos = Repo.repos_needing_help_for_user(User.new( :favorite_languages => [ "ruby" ])).map(&:path)
    assert_equal [ "bemurphy/issue_triage_sandbox", "rails/rails" ], repos
  end

  test "repos needing help when user has no languages" do
    repos = Repo.repos_needing_help_for_user(User.new( :favorite_languages => [ ])).map(&:path)
    assert_equal [ "bemurphy/issue_triage_sandbox", "rails/rails" , "joyent/node"], repos
  end

  test "repos needing help when user is null" do
    repos = Repo.repos_needing_help_for_user(nil).map(&:path)
    assert_equal [ "bemurphy/issue_triage_sandbox", "rails/rails" , "joyent/node"], repos
  end

  test "check existence of repo by its name and user's name" do
    assert Repo.exists_with_name?("bemurphy/issue_triage_sandbox")
    refute Repo.exists_with_name?("prathamesh-sonpatki/issue_triage_sandbox")
  end

  test "#issues_url returns issues url" do
    repo = Repo.new(name: 'codetriage', user_name: 'codetriage')
    assert_equal "https://github.com/codetriage/codetriage/issues", repo.issues_url
  end

  test "#api_issues_url returns issues url with Github api" do
    repo = Repo.new(name: 'codetriage', user_name: 'codetriage')
    assert_equal "https://api.github.com/repos/codetriage/codetriage/issues", repo.api_issues_url
  end

  test "search_by returns repo by name and user_name" do
    repo1 = Repo.create(name: 'codetriage', user_name: 'codetriage')
    repo2 = Repo.create(name: 'rails', user_name: 'rails')

    assert_equal [repo1], Repo.search_by('codetriage', 'codetriage')
  end
 end
