require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  fixtures :users

  def test_other_static_pages
    get :what
    assert_response :success, 'successfully renders "what" page'
    get :privacy
    assert_response :success, 'successfully renders privacy page'
    get :support
    assert_response :success, 'successfully renders support page'
  end

  def test_cache_control
    get :index
    assert_equal("no-cache, no-store", response.headers["Cache-Control"])
    assert_equal("no-cache", response.headers["Pragma"])
    assert_equal("Fri, 01 Jan 1990 00:00:00 GMT", response.headers["Expires"])
  end

  test "signed in user" do
    sign_in users(:mockstar)
    get :index

    assert_response :success, 'successfully renders index'
    assert_not_nil assigns(:repos), 'assigns to repos'
    assert_not_nil assigns(:repos_subs), 'assigns to repos_subs'
    assert_template :index, 'render index template'

    test_other_static_pages
  end

  test "not signed in user" do
    get :index
    assert_response :success, 'successfully renders index'
    assert_nil assigns(:repos_subs), 'not assigns to repos_subs'
    assert_template :index, 'render index template'
    test_other_static_pages
  end

  test "cache control for headers" do
    test_cache_control
    sign_in users(:mockstar)
    test_cache_control
  end
end
