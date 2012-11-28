require "test_helper"

class MaintainingRepoSubscriptionsTest < ActionController::IntegrationTest
  fixtures :repos

  def triage_the_sandbox
    login_via_github
    visit "/"
    click_link "bemurphy/issue_triage_sandbox"
    click_button "I Want to Triage: bemurphy/issue_triage_sandbox"
  end

  test "subscribing to a repo" do
    triage_the_sandbox
    assert page.has_content?("Repos you are helping")
    assert page.has_content?("bemurphy/issue_triage_sandbox")
  end

  test "unsubscribing to a repo" do
    triage_the_sandbox
    click_link "Quit triaging"
    assert page.has_content?("Repos you are helping")
    refute page.has_content?("https://github.com/bemurphy/issue_triage_sandbox")
  end

  test "listing subscribers" do
    triage_the_sandbox
    click_link 'bemurphy/issue_triage_sandbox'
    click_link 'View subscribers'
    assert page.has_content?("Mock Star")
  end
end
