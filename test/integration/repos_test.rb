require 'test_helper'

class ReposTest < ActionController::TestCase

  test "regular repo routes" do
    assert_routing(
      'rails/rails',
      {controller: "repos", action: "show", full_name: "rails/rails"},
    )
  end

  test "repo index" do
    assert_routing('repos', {controller: "repos", action: "index"})
  end

  test "repo subscriber route" do
    assert_routing(
      'rails/rails/subscribers',
      {controller: "subscribers", action: "show", full_name: "rails/rails"})
  end

  test "route with .js in it" do
    assert_routing(
      'angular/angular.js',
      {controller: "repos", action: "show", full_name: "angular/angular.js"},
    )
  end


end
