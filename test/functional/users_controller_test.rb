# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test '#show' do
    sign_in users(:mockstar)
    user = users(:jroes)

    get :show, params: { id: user.id }

    assert_redirected_to root_path
  end

  test '#update should update an user' do
    user = users(:mockstar)
    sign_in user

    put :update, params: { user: { name: 'New Name' } }
    user.reload

    assert_redirected_to user
    assert_equal 'New Name', user.name
  end

  test '#token_delete' do
    sign_in users(:schneems)

    get :token_delete, params: { account_delete_token: users(:schneems).account_delete_token }

    assigns(:lonely_repos).any?
  end

  test 'should destroy a user with the correct account_delete_token' do
    sign_in users(:mockstar)

    assert_difference "User.count", -1 do
      delete :token_destroy, params: { account_delete_token: users(:mockstar).account_delete_token }
    end
  end
end
