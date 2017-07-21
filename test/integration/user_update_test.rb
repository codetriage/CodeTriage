require 'test_helper'

class UserUpdateTest < ActionDispatch::IntegrationTest
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

  test 'updating the user email_frequency' do
    @user = users(:mockstar)
    login_as(@user, scope: :user)
    visit edit_user_path(@user)
    select 'Twice a week', from: 'Email Frequency'
    click_button 'Save'
    assert page.has_content?('User successfully updated')
    visit edit_user_path(@user)
    assert page.has_select?('Email Frequency', selected: 'Twice a week')
    @user.reload
    assert_equal @user.email_frequency, 'twice_a_week'
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

  test 'updating the user email_time_of_day' do
    @user = users(:mockstar)
    login_as(@user, scope: :user)
    visit edit_user_path(@user)
    select '05:00 UTC', from: 'Email time of day'
    click_button 'Save'
    assert page.has_content?('User successfully updated')
    visit edit_user_path(@user)
    assert page.has_select?('Email time of day', selected: '05:00 UTC')
    @user.reload
    assert_equal @user.email_time_of_day, '2000-01-01 05:00:00 UTC'
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
