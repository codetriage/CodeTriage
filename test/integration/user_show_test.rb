require 'test_helper'

class UserShowTest < ActionDispatch::IntegrationTest
  def setup
    @user_mockstar = users(:mockstar)
    @user_schneems = users(:schneems)
    @h1_expected = 'Help out your favorite open source projects and become a better developer while doing it.'
  end

  test 'should redirect profile page when not logged in' do
    visit user_path(@user_mockstar)
    assert page.has_css?('h1', text: @h1_expected)
    visit user_path(@user_schneems)
    assert page.has_css?('h1', text: @h1_expected)
  end

  test 'should redirect users from profiles other than their own' do
    login_as(@user_mockstar, scope: :user)
    visit user_path(@user_schneems)
    assert page.has_css?('h1', text: @h1_expected)
  end

  test 'should not redirect users from their own profiles' do
    login_as(@user_mockstar, scope: :user)
    visit user_path(@user_mockstar)
    assert page.has_css?('h1', text: 'mockstar')
    assert page.has_css?('h2', text: 'mockstar@example.com')
    assert page.has_css?('h2', text: 'Settings')
    assert page.has_css?('h3', text: 'Is your account shown to everyone:')
    assert page.has_css?('h3', text: 'Email frequency:')
    assert page.has_css?('h3', text: 'Email time of day:')
    assert page.has_css?('h3', text: 'Max number of issues you want to receive per day:')
    assert page.has_css?('h3', text: 'Skip Issues with Pull Requests:')
    assert page.has_css?('h2', text: 'Select your favorite languages:')
  end

  test 'user should have link to own profile' do
    login_as(@user_mockstar, scope: :user)
    visit root_path
    assert page.has_link?('mockstar', href: user_path(@user_mockstar))
  end
end
