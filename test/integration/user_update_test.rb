require 'test_helper'

class UserUpdateTest < ActionDispatch::IntegrationTest

  # https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
  include Warden::Test::Helpers
  Warden.test_mode!

  test "routing" do
    user = users(:mockstar)
    assert_routing user_path(user), { controller: 'users', action: 'show', id: user.id.to_s }
  end

  test 'updating the user email address' do
    @user = users(:mockstar)
    login_as(@user, scope: :user)
    visit edit_user_path(@user)
    fill_in 'Email', with: 'newemail@me.com'
    click_button 'Save'
    assert page.has_content?('User successfully updated')
  end

  test 'updating the user daily_issue_limit' do
    @user = users(:mockstar)
    login_as(@user, scope: :user)
    visit edit_user_path(@user)
    fill_in 'Max # of issues you want to receive per day', with: '1'
    click_button 'Save'
    assert page.has_content?('User successfully updated')
    @user.reload
    assert_equal @user.daily_issue_limit, 1
  end

  test 'updating the user daily_issue_limit to unlimited' do
    @user = users(:mockstar)
    login_as(@user, scope: :user)
    visit edit_user_path(@user)
    fill_in 'Max # of issues you want to receive per day', with: ''
    click_button 'Save'
    assert page.has_content?('User successfully updated')
    @user.reload
    assert_nil @user.daily_issue_limit
  end

  test 'updating the users skip_issues_with_pr setting to true' do
    @user = users(:mockstar)
    login_as(@user, scope: :user)
    visit edit_user_path(@user)
    check 'user_skip_issues_with_pr'
    click_button 'Save'
    assert page.has_content?('User successfully updated')
    @user.reload
    assert @user.skip_issues_with_pr
  end

  test 'updating the users skip_issues_with_pr setting to false' do
    @user = users(:mockstar)
    login_as(@user, scope: :user)
    visit edit_user_path(@user)
    uncheck 'user_skip_issues_with_pr'
    click_button 'Save'
    assert page.has_content?('User successfully updated')
    @user.reload
    assert_equal false, @user.skip_issues_with_pr
  end
end
