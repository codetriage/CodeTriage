# frozen_string_literal: true

require 'test_helper'

class ReposTest < ActionDispatch::IntegrationTest
  test "regular repo routes" do
    assert_routing(
      'rails/rails',
      { controller: "repos", action: "show", full_name: "rails/rails" },
    )
  end

  test "repo index" do
    assert_routing('repos', { controller: "repos", action: "index" })
  end

  test "repo subscriber route" do
    assert_routing(
      'rails/rails/subscribers',
      { controller: "subscribers", action: "show", full_name: "rails/rails" }
    )
  end

  test "route with .js in it" do
    assert_routing(
      'angular/angular.js',
      { controller: "repos", action: "show", full_name: "angular/angular.js" },
    )
  end

  test "valid repo" do
    get repo_url 'rails/rails'
    assert_response :success
  end

  test "deleted_from_github repo" do
    get repo_url 'repo/deleted'
    assert_redirected_to new_repo_url(user_name: 'repo', name: 'deleted')
  end

  test "archived repo" do
    get repo_url 'repo/archived'
    assert_redirected_to new_repo_url(user_name: 'repo', name: 'archived')
  end
end
