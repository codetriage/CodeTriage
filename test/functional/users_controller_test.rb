# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test 'should destroy a user with the correct account_delete_token' do
    sign_in users(:mockstar)

    assert_difference "User.count", -1 do
      delete :token_destroy, params: { account_delete_token: users(:mockstar).account_delete_token }
    end
  end

  test "show user" do
    sign_in users(:mockstar)
    get :show, params: { id: users(:mockstar).id }
    assert(response.status == 200)
  end
 
  test "update user" do
    sign_in users(:mockstar)
    patch :update, params: { id: users(:mockstar).id, user: { name: 'new name' } }
    assert(User.find(users(:mockstar).id).name == 'new name')
  end

  test "don´t update user with invalid email" do
    sign_in users(:mockstar)
    patch :update, params: { id: users(:mockstar).id, user: { email: 'wrong_email' } }
    assert(User.find(users(:mockstar).id).email != 'wrong_email')
  end

  test "update with blanck email" do
    sign_in users(:mockstar)
    patch :update, params: { id: users(:mockstar).id, user: { email: '' } }
    assert(User.find(users(:mockstar).id).email == "")
  end

  test "update with valid email" do
    sign_in users(:mockstar)
    patch :update, params: { id: users(:mockstar).id, user: { email: 'valid@email.com'}}
    assert(User.find(users(:mockstar).id).email == 'valid@email.com')
  end

 
end
