require 'test_helper'

class UserUnsubscribeTest < ActionDispatch::IntegrationTest

  # https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
  include Warden::Test::Helpers
  Warden.test_mode!

  test 'unsubscribing successfully' do
    @user = users(:mockstar)
    token = @user.account_delete_token
    login_as(@user, scope: :user)

    visit token_delete_user_path(token)
    click_on "Yes, Delete My Account"

    assert page.has_content?('Successfully removed your user account')
  end

  test 'unsubscribing more than once' do
    @user = users(:mockstar)
    token = @user.account_delete_token
    login_as(@user, scope: :user)

    visit token_delete_user_path(token)
    click_on "Yes, Delete My Account"

    visit token_delete_user_path(token)

    assert page.has_content?('Account could not be found. You may have already deleted it, or your GitHub username may have changed.')
  end
end
