require 'test_helper'

class ReposTest < ActionController::TestCase

  test "regular repo routes" do
    assert_routing(
      'rails/rails',
      {controller: "repos", action: "show", full_name: "rails/rails"},
    )
    assert_routing('repos', {controller: "repos", action: "index"})
  end

  test "repo subscriber route" do
    assert_routing(
      'rails/rails/subscribers',
      {controller: "subscribers", action: "show", full_name: "rails/rails"})
  end

end
