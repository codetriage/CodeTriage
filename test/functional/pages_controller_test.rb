require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :users

  context 'when user signed in' do
    setup do
      sign_in users(:mockstar)
      get :index
    end

    should 'successfully renders index' do
      assert_response :success
    end

    should 'assigns to repos' do
      assert_not_nil assigns(:repos)
    end

    should 'assigns to repos_subs' do
      assert_not_nil assigns(:repos_subs)
    end

    should 'render index template' do
      assert_template :index
    end

    should 'render home layout' do
      assert_template layout: 'home'
    end
  end

  context 'when user is not signed in' do
    should 'not assigns to repos_subs' do
      get :index
      assert_nil assigns(:repos_subs)
    end
  end
end
