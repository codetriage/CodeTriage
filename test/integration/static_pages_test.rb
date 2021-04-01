require 'test_helper'

class StaticPagesTest < ActionDispatch::IntegrationTest
  def test_footer
    # Link to Schneems
    assert page.has_link?(href: 'https://www.schneems.com')

    # Link to thoughtbot
    assert page.has_link?(href: 'https://thoughtbot.com')

    # Link to Heroku
    assert page.has_link?(href: 'https://www.heroku.com')

    # Link to the "What" page
    assert page.has_link?('What is CodeTriage?', href: what_path)

    # Link to the privacy policy
    assert page.has_link?('Privacy', href: privacy_path)

    # Link to the support page
    assert page.has_link?('Support', href: support_path)

    # Fork us on GitHub
    assert page.has_link?('Fork us on GitHub', href: 'https://github.com/codetriage/codetriage')
  end

  def test_common_index
    visit root_path

    test_footer
    h1_expected = 'Help out your favorite open source projects and become a better developer while doing it.'
    assert page.has_css?('h1', text: h1_expected)
    summary = 'Pick your favorite repos to receive a different open issue in your inbox every day.'
    assert page.has_text?(summary)
  end

  def test_what
    visit root_path
    click_link('What is CodeTriage?', match: :first)

    test_footer
    assert page.has_css?('h1', text: 'What is CodeTriage?')
    assert page.has_css?('h2', text: 'History')
    assert page.has_css?('h2', text: 'Results')
    assert page.has_css?('h2', text: 'Future')
    assert page.has_text?('Free community tools for contributing to Open Source projects')
    assert page.has_text?('building a habit of involvement')
    assert page.has_text?('democratize the process and spread the load around')
  end

  def test_privacy
    visit root_path
    click_on 'Privacy Policy'

    test_footer
    assert page.has_css?('h1', text: 'Privacy Policy')
    assert page.has_css?('h2', text: 'When do we collect information?')
    assert page.has_css?('h2', text: 'How do we use your information?')
    assert page.has_css?('h2', text: 'How do we protect your information?')
    assert page.has_css?('h2', text: 'Third-party disclosure')
    assert page.has_css?('h2', text: 'Third-party links')
    assert page.has_css?('h2', text: 'California Online Privacy Protection Act')
    assert page.has_text?('Your personal information is contained behind secured networks')
    assert page.has_text?('We do not sell, trade, or otherwise transfer')
    assert page.has_text?('Users can visit our site anonymously.')
  end

  def test_support
    visit root_path
    click_on 'Support'

    test_footer
    assert page.has_css?('h1', text: 'Support')
    assert page.has_text?('All support is provided via GitHub issues')
  end

  def test_common
    test_common_index
    test_what
    test_privacy
    test_support
  end

  test 'static pages have expected content and links' do
    test_common
    assert page.has_link?('Log in', href: user_github_omniauth_authorize_path)

    # Logged in
    @user_mockstar = users(:mockstar)
    login_as(@user_mockstar, scope: :user)
    test_common
    visit root_path
    assert page.has_link?('Sign Out', href: destroy_user_session_path)
  end
end
