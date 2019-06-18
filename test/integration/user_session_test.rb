# frozen_string_literal: true

require 'test_helper'

class UserSessionTest < ActionDispatch::IntegrationTest
  test "sign_in screen renders" do
    visit new_user_session_path
    assert page.has_content?('Sign in')
  end
end
