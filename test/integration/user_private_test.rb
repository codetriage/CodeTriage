require 'test_helper'

class UserPrivateTest < ActionDispatch::IntegrationTest
  def add_subscription(new_user)
    @repo = repos(:issue_triage_sandbox)
    @repo_sub_new_user = new_user.repo_subscriptions.new
    @repo_sub_new_user.repo = @repo
    @repo_sub_new_user.save
  end

  def load_subscriptions
    @user_mockstar = users(:mockstar)
    @user_schneems = users(:schneems)
    @user_schneems.avatar_url = 'http://gravatar.com/avatar/schneems'
    @user_schneems.save
    @user_foo = users(:foo_user)
    @user_foo.avatar_url = 'http://gravatar.com/avatar/foo'
    @user_foo.save
    @user_bar = users(:bar_user)
    @user_bar.avatar_url = 'http://gravatar.com/avatar/bar'
    @user_bar.private = true
    @user_bar.save
    @user_jroes = users(:jroes)
    @user_jroes.avatar_url = 'http://gravatar.com/avatar/jroes'
    @user_jroes.save
    @user_empty = users(:empty)
    @user_empty.avatar_url = 'http://gravatar.com/avatar/empty'
    @user_empty.save
    add_subscription(@user_jroes)
    add_subscription(@user_empty)
  end

  def xpath_img(url_avatar)
    str1 = './/img[@src="'
    str2 = url_avatar
    str3 = '"]'
    output = "#{str1}#{str2}#{str3}"
    output
  end

  def check_public_user(user1)
    page.assert_selector(:xpath, xpath_img(user1.avatar_url))
    assert page.has_link?(href: user1.github_url)
  end

  def check_private_user(user1)
    assert_not page.has_link?(href: user1.github_url)
  end

  test 'display only public users' do
    load_subscriptions
    login_as(@user_mockstar, scope: :user)
    visit root_path
    click_on 'bemurphy/issue_triage_sandbox'
    check_public_user(@user_schneems)
    check_public_user(@user_foo)
    check_private_user(@user_bar)
    check_private_user(@user_jroes)
  end

  test 'user can switch between public and private' do
    @user_bar = users(:bar_user)
    login_as(@user_bar, scope: :user)
    visit root_path
    click_on 'bar_user'
    click_on 'Go private'
    click_on 'Go public'
    click_on 'Go private'
    click_on 'Go public'
  end
end
