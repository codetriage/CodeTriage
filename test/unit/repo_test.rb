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
end
