require "test_helper"

class AddingReposTest < ActionController::IntegrationTest
  test "adding a new valid repo" do
    visit "/"
    click_link "Add a Repo"
    fill_in 'repo_user_name', :with => 'bemurphy'
    fill_in 'repo_name', :with => 'issue_triage_sandbox'
    click_button "Add Repo"
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
