require 'test_helper'

class ReposControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :users, :repos

  test 'responds with 404 if repo does not exist' do
    assert_raise(ActiveRecord::RecordNotFound) {
      get :show, full_name: 'foo/bar'
    }
  end

  test 'trying to create repo without logged in will redirect to login page' do
    assert_no_difference -> { Repo.count } do
      post :create, repo: { name: 'codetriage', user_name: 'codetriage' }
    end

    assert_redirected_to new_user_session_path
  end

  test 'logged in user can create repo' do
    sign_in users(:mockstar)

    assert_difference -> { Repo.count } do
      post :create, repo: { name: 'refinerycms', user_name: 'refinery' }
    end

    assert_redirected_to repo_path('refinery/refinerycms')
  end
end
