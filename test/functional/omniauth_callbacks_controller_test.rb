require 'test_helper'

class Users::OmniauthCallbacksControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
  end

  test "make user feel good when legit email address" do
    stub_oauth_user('legit@legit.com')
    get :github
    assert flash[:notice] == I18n.t("devise.omniauth_callbacks.success",
                                    kind: "GitHub")
  end

  test "redirect to user page and inform when bad e-mail address" do
    user = stub_oauth_user('awful e-mail address')
    get :github
    assert flash[:notice] == I18n.t("devise.omniauth_callbacks.bad_email_success",
                                    kind: "GitHub")
    assert_redirected_to edit_user_path(user)
  end

  def stub_oauth_user(email)
    user = User.new(email: email)
    user.stubs(:persisted?).returns(true)
    GitHubAuthenticator.stubs(:authenticate).returns(user)
    user
  end
end
