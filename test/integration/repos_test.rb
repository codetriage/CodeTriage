require 'test_helper'

class ReposTest < ActionController::TestCase

  test "regular repo routes" do
    assert_routing(
      'rails/rails',
      {controller: "repos", action: "show", user_name: "rails", name: "rails"},
    )
    assert_routing('repos', {controller: "repos", action: "index"})
  end

end