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
      assert_equal "An extendable Ruby on Rails 'CMS framework' that supports Rails 3.2", repo.description
    end
  end

  test "counts number of subscribers" do
    repo = Repo.create :user_name => 'Refinery', :name => 'Refinerycms'
    repo.users << users(:jroes)
    repo.users << users(:schneems)
    repo.subscriber_count == 2
  end

  test "returns all languages" do
    Repo.create :user_name => "rails", :name => "rails", :language => "Ruby"
    Repo.create :user_name => "joyent", :name => "node", :language => "Javascript"
    Repo.create :user_name => "pydata", :name => "pandas", :language => "Python"
    Repo.create :user_name => "netty", :name => "netty", :language => "Java"

    assert_equal ["Ruby", "Python", "Java", "Javascript"],  Repo.languages
  end

  test "returns repos filtered by language" do
    Repo.create :user_name => "rails", :name => "rails", :language => "Ruby"
    Repo.create :user_name => "joyent", :name => "node", :language => "Javascript"
    repo = Repo.create :user_name => "pydata", :name => "pandas", :language => "Python"
    Repo.create :user_name => "netty", :name => "netty", :language => "Java"

    assert_equal [ repo ], Repo.filter_by_language("Python")

    assert_equal 5, Repo.filter_by_language.size
  end
end
