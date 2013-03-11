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
end


