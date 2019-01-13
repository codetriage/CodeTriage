require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  fixtures :users

  def load_users
    @u1 = users(:mockstar) # public
    @u2 = users(:foo_user) # public
    @u3 = users(:bar_user) # public
    @u4 = users(:schneems) # public
    @u5 = users(:jroes) # private
    @u6 = users(:empty) # public
  end

  def view_own_profile(u)
    sign_in u
    get :show, params: { id: u.id }
    assert_response :success
    sign_out u
  end

  # BEGIN: SHOW
  # BEGIN: show-public
  test 'should redirect profile page when not logged in' do
    load_users
    get :show, params: { id: @u1.id }
    assert_redirected_to root_path
    get :show, params: { id: @u2.id }
    assert_redirected_to root_path
    get :show, params: { id: @u3.id }
    assert_redirected_to root_path
    get :show, params: { id: @u4.id }
    assert_redirected_to root_path
    get :show, params: { id: @u5.id }
    assert_redirected_to root_path
    get :show, params: { id: @u6.id }
    assert_redirected_to root_path
  end
  # END: show-public

  # BEGIN: show-other_user
  test 'should redirect users from profiles other than their own' do
    load_users
    sign_in @u1
    get :show, params: { id: @u2.id }
    assert_redirected_to root_path
    get :show, params: { id: @u3.id }
    assert_redirected_to root_path
    get :show, params: { id: @u4.id }
    assert_redirected_to root_path
    get :show, params: { id: @u5.id }
    assert_redirected_to root_path
    get :show, params: { id: @u6.id }
    assert_redirected_to root_path
  end
  # END: show-other_user

  # BEGIN: show-self
  test 'should not redirect users from their own profiles' do
    load_users
    view_own_profile(@u1)
    view_own_profile(@u2)
    view_own_profile(@u3)
    view_own_profile(@u4)
    view_own_profile(@u5)
    view_own_profile(@u6)
  end
  # END: show-self

  test 'should destroy a user with the correct account_delete_token' do
    sign_in users(:mockstar)

    assert_difference "User.count", -1 do
      delete :token_destroy, params: { account_delete_token: users(:mockstar).account_delete_token }
    end
  end
end
