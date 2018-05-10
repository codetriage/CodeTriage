require 'test_helper'

class UserUnsubscribeTest < ActionDispatch::IntegrationTest
  test 'unsubscribing successfully' do
    @user = users(:mockstar)
    token = @user.account_delete_token
    login_as(@user, scope: :user)

    visit token_delete_user_path(token)
    click_on "destroy_user"

    assert page.has_content?('Successfully removed your user account')
  end

  test 'unsubscribing more than once' do
    @user = users(:mockstar)
    token = @user.account_delete_token
    login_as(@user, scope: :user)

    visit token_delete_user_path(token)
    click_on "destroy_user"

    visit token_delete_user_path(token)

    assert page.has_content?('Account could not be found. You may have already deleted it, or your GitHub username may have changed.')
  end
end
