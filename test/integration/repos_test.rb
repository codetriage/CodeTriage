# frozen_string_literal: true

require "test_helper"

class ReposTest < ActionDispatch::IntegrationTest
  test "regular repo routes" do
    assert_routing(
      "rails/rails",
      {controller: "repos", action: "show", full_name: "rails/rails"}
    )
  end

  test "repo index" do
    assert_routing("repos", {controller: "repos", action: "index"})
  end

  test "repo subscriber route" do
    assert_routing(
      "rails/rails/subscribers",
      {controller: "subscribers", action: "show", full_name: "rails/rails"}
    )
  end

  test "route with .js in it" do
    assert_routing(
      "angular/angular.js",
      {controller: "repos", action: "show", full_name: "angular/angular.js"}
    )
  end

  test "access valid repo" do
    get repo_url "rails/rails"
    assert_response :success
  end

  test "access deleted_from_github repo" do
    get repo_url "empty/deleted"
    assert_redirected_to new_repo_url(user_name: "empty", name: "deleted")
  end

  test "access archived repo" do
    get repo_url "empty/archived"
    assert_redirected_to new_repo_url(user_name: "empty", name: "archived")
  end

  test "edit repo where user is not the owner" do
    login_as(users(:empty))
    get edit_repo_url "rails/rails"
    assert_redirected_to root_path
  end

  test "edit deleted_from_github repo" do
    login_as(users(:empty))
    get edit_repo_url "empty/deleted"
    assert_response :success
  end

  test "edit archived repo" do
    login_as(users(:empty))
    get edit_repo_url "empty/archived"
    assert_response :success
  end

  test "update repo" do
    login_as(users(:empty))
    repo = repos(:archived_repo)
    assert_changes -> {
      repo.notes
    } do
      patch repo_url "empty/archived", params: {repo: {notes: "Updated notes"}}
      repo.reload
    end
    assert_redirected_to repo_url "empty/archived"
  end
end
