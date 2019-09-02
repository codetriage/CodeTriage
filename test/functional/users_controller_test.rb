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
end
