require 'test_helper'

class RepoTest < ActiveSupport::TestCase
  test "normalizing names to lowercase" do
    repo = Repo.create :user_name => 'Refinery', :name => 'Refinerycms'
    assert_equal "refinery", repo.user_name
    assert_equal "refinerycms", repo.name
  end

  test "uniqueness of repo with case insensitivity" do
    repo = Repo.create :user_name => 'refinery', :name => 'refinerycms'
    duplicate_repo = Repo.create :user_name => 'Refinery', :name => 'Refinerycms'
    assert_equal ["has already been taken"], duplicate_repo.errors[:name]
  end

  test "update repo info from github" do
    VCR.use_cassette "repo_info" do
      repo = Repo.new :user_name => 'refinery', :name => 'refinerycms'
      repo.update_from_github
      assert_equal "Ruby", repo.language
      assert_equal "An extendable Ruby on Rails CMS that supports Rails 3.2", repo.description
    end
  end

  test "update repo info from github error" do
    VCR.use_cassette "repo_info_error" do
      repo = Repo.new :user_name => 'codetriage', :name => 'codetriage'
      assert_raise(GitHubBub::RequestError) { repo.update_from_github }
    end
  end

  test "counts number of subscribers" do
    repo = Repo.create :user_name => 'Refinery', :name => 'Refinerycms'
    repo.users << users(:jroes)
    repo.users << users(:schneems)
    repo.subscriber_count == 2
  end
end
