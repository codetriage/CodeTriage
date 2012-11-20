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
    assert page.has_content?("Repos you are Triaging")
    assert page.has_link?("bemurphy/issue_triage_sandbox")
  end

  test "unsubscribing to a repo" do
    triage_the_sandbox
    click_link "Quit"
    assert page.has_content?("Repos you are Triaging")
    refute page.has_link?("bemurphy/issue_triage_sandbox")
  end
end
