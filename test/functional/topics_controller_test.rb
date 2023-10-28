# frozen_string_literal: true

require "test_helper"

class TopicsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "redirect invalid topic" do
    get :show, params: {id: "test"}
    assert_redirected_to root_url
  end
end
