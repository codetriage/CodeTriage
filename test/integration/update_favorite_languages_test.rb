require 'test_helper'

class UpdateFavoriteLanguagesTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.first
    @user.favorite_languages = ["ruby"]
    @user.save
    visit user_path @user
  end

  test 'clears favorite languages' do
    uncheck 'user_favorite_languages_ruby'
    click_button 'Save'
    @user.reload
    assert_equal [], @user.favorite_languages
    assert page.has_content? 'User successfully updated'
  end

  test 'adds more favorite languages' do
    check 'user_favorite_languages_javascript'
    click_button 'Save'
    @user.reload
    assert_equal ["javascript", "ruby"], @user.favorite_languages.sort
    assert page.has_content? 'User successfully updated'
  end
end
