require 'test_helper'

class UniversityControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test 'when picking a repo' do
    get :show, params: { id: 'picking_a_repo' }

    assert_response :success, 'successfully renders show'
    assert_not_nil assigns(:page_title), 'assigns page title'
    assert_equal assigns(:page_title), 'Picking the Right Repo(s)'
    assert_template :picking_a_repo, 'render picking_a_repo show template'
  end

  test 'when example_app' do
    get :show, params: { id: 'example_app' }

    assert_response :success, 'successfully renders show'
    assert_not_nil assigns(:page_title), 'assigns page title'
    assert_equal assigns(:page_title), 'Please Provide an Example App'
    assert_template :example_app, 'render example_app show template'
  end

  test 'when example_apps' do
    get :show, params: { id: 'example_apps' }

    assert_response :success, 'successfully renders show'
    assert_not_nil assigns(:page_title), 'assigns page title'
    assert_equal assigns(:page_title), 'Please Provide an Example App'
    assert_template :example_app, 'render example_app show template'
  end

  test 'when example-app' do
    get :show, params: { id: 'example-app' }

    assert_response :success, 'successfully renders show'
    assert_not_nil assigns(:page_title), 'assigns page title'
    assert_equal assigns(:page_title), 'Please Provide an Example App'
    assert_template :example_app, 'render example_app show template'
  end

  test 'when example-apps' do
    get :show, params: { id: 'example-apps' }

    assert_response :success, 'successfully renders show'
    assert_not_nil assigns(:page_title), 'assigns page title'
    assert_equal assigns(:page_title), 'Please Provide an Example App'
    assert_template :example_app, 'render example_app show template'
  end
end
