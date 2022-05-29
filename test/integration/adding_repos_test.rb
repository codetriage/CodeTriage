# frozen_string_literal: true

require "test_helper"

class AddingReposTest < ActionDispatch::IntegrationTest
  teardown do
    Rails.cache.clear
  end

  test "adding a new valid repo passing the URL" do
    login_via_github
    VCR.use_cassette('my_repos') do
      visit "/"
      click_link "Submit a Repo"

      fill_in 'url', with: 'https://github.com/bemurphy/issue_triage_sandbox'

      click_button "Add Repo"
    end

    VCR.use_cassette('add_valid_repo') do
      assert page.has_content?("Added bemurphy/issue_triage_sandbox for triaging")
    end
  end

  test "modifies the URL when it has invalid params" do
    login_via_github
    VCR.use_cassette('my_repos') do
      visit "/"
      click_link "Submit a Repo"

      fill_in 'url', with: 'https://github.com/bemurphy/issue_triage_sandbox?files=1'

      click_button "Add Repo"
    end

    VCR.use_cassette('add_valid_repo') do
      assert page.has_content?("Added bemurphy/issue_triage_sandbox for triaging")
    end
  end

  test "supports URL without github.com" do
    visit "/"
    login_via_github

    VCR.use_cassette('my_repos') do
      visit "/"
      click_link "Submit a Repo"
      fill_in 'url', with: 'bemurphy/issue_triage_sandbox'

      click_button "Add Repo"
    end

    VCR.use_cassette('add_valid_repo') do
      assert page.has_content?("Added bemurphy/issue_triage_sandbox for triaging")
    end
  end

  test "adding invalid repo with blank params" do
    login_via_github
    VCR.use_cassette('blank_repo') do
      visit "/"
      click_link "Submit a Repo"

      click_button "Add Repo"
    end

    assert page.has_content? "can't be blank"
  end

  test "add page without login" do
    # do not login first
    VCR.use_cassette('blank_repo') do
      visit "/somerando/project"
    end

    assert page.has_content? "You must be logged in"
  end
end
