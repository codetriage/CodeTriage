require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures :users

  test 'should destroy a user with the correct account_delete_token' do

    assert_difference "User.count", -1 do
      delete :token_destroy, account_delete_token: users(:mockstar).account_delete_token
    end
  end
end
