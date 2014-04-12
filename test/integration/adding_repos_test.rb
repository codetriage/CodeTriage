require "test_helper"

class AddingReposTest < ActionDispatch::IntegrationTest

  teardown do
    Rails.cache.clear
  end

  test "adding a new valid repo" do
    login_via_github
    VCR.use_cassette('my_repos') do
      visit "/"
      click_link "Submit a Repo"

      fill_in 'repo_user_name', :with => 'bemurphy'
      fill_in 'repo_name',      :with => 'issue_triage_sandbox'

      within '#new_repo_from_names' do
        click_button "Add Repo"
      end
    end

    VCR.use_cassette('add_valid_repo') do
      assert page.has_content?("Added bemurphy/issue_triage_sandbox for triaging")
    end
  end

  test "adding a new valid repo passing the URL" do
    login_via_github
    VCR.use_cassette('my_repos') do
      visit "/"
      click_link "Submit a Repo"

      fill_in 'url', :with => 'https://github.com/bemurphy/issue_triage_sandbox'
      fill_in 'repo_name',      :with => ''

      within '#new_repo_from_url' do
        click_button "Add Repo"
      end
    end

    VCR.use_cassette('add_valid_repo') do
      assert page.has_content?("Added bemurphy/issue_triage_sandbox for triaging")
    end
  end


  # TODO: Pending for now but we should enable this, there's an env change in repo that
  # treats all repo urls as valid in test.  Fix this one that is removed
  # test "adding an invalid repo" do
  #   VCR.use_cassette('add_invalid_repo') do
  #     visit "/"
  #     click_link "Add a Repo"
  #     fill_in 'repo_user_name', :with => 'bemurphy'
  #     fill_in 'repo_name', :with => 'issue_triage_bogus_repo'
  #     click_button "Add Repo"
  #     assert page.has_content?("you mistyped something?")
  #   end
  # end
end
