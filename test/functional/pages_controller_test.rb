require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  fixtures :users

  test "siged in user" do
    sign_in users(:mockstar)
    get :index

    assert_response :success, 'successfully renders index'
    assert_not_nil assigns(:repos), 'assigns to repos'
    assert_not_nil assigns(:repos_subs), 'assigns to repos_subs'
    assert_template :index, 'render index template'
  end

  test "not signed in user" do
    get :index
    assert_nil assigns(:repos_subs), 'not assigns to repos_subs'
  end

  test "cache control for headers" do
    get :index
    assert_equal("no-cache, no-store", response.headers["Cache-Control"])
    assert_equal("no-cache", response.headers["Pragma"])
    assert_equal("Fri, 01 Jan 1990 00:00:00 GMT", response.headers["Expires"])
  end
end
