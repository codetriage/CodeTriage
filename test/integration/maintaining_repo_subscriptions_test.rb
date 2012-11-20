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


  end

  test "unsubscribing to a repo" do
    triage_the_sandbox



  end
end
