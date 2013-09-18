require 'test_helper'

class UserUpdateTest < ActionController::IntegrationTest
  test 'updating the user email address' do
    @user = User.first
    visit edit_user_path(@user)
    fill_in 'Email', :with => 'newemail@me.com'
    click_button 'Save'
    assert page.has_content?('User successfully updated')
    assert_routing user_path(@user), { :controller => 'users', :action => 'show', :id => '1' }
  end

  test 'updating the user daily_issue_limit' do
    @user = User.first
    visit edit_user_path(@user)
    fill_in 'Max # of issues you want to receive per day', :with => '1'
    click_button 'Save'
    assert page.has_content?('User successfully updated')
    @user.reload
    assert_equal @user.daily_issue_limit, 1
    assert_routing user_path(@user), { :controller => 'users', :action => 'show', :id => '1' }
  end

  test 'updating the user daily_issue_limit to unlimited' do
    @user = User.first
    visit edit_user_path(@user)
    fill_in 'Max # of issues you want to receive per day', :with => ''
    click_button 'Save'
    assert page.has_content?('User successfully updated')
    @user.reload
    assert_nil @user.daily_issue_limit
    assert_routing user_path(@user), { :controller => 'users', :action => 'show', :id => '1' }
  end

  test 'updating the users skip_issues_with_pr setting to true' do
    @user = User.first
    visit edit_user_path(@user)
    check 'user_skip_issues_with_pr'
    click_button 'Save'
    assert page.has_content?('User successfully updated')
    @user.reload
    assert @user.skip_issues_with_pr
    assert_routing user_path(@user), { :controller => 'users', :action => 'show', :id => '1' }
  end

  test 'updating the users skip_issues_with_pr setting to false' do
    @user = User.first
    visit edit_user_path(@user)
    uncheck 'user_skip_issues_with_pr'
    click_button 'Save'
    assert page.has_content?('User successfully updated')
    @user.reload
    assert_equal false, @user.skip_issues_with_pr
    assert_routing user_path(@user), { :controller => 'users', :action => 'show', :id => '1' }
  end
end
