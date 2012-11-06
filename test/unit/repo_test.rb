require 'test_helper'

class RepoTest < ActiveSupport::TestCase
  test "uniqueness of repo" do
    repo = Repo.create :user_name => 'refinery', :name => 'refinerycms'
    duplicate_repo = Repo.create :user_name => 'refinery', :name => 'refinerycms'
    assert_equal ["has already been taken"], duplicate_repo.errors[:name]
  end
end
