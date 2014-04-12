require "test_helper"

class MaintainingRepoSubscriptionsTest < ActionDispatch::IntegrationTest
  fixtures :repos

  def triage_the_sandbox
    login_via_github
    visit "/"
    click_link "issue_triage_sandbox"
    click_button "I Want to Triage: bemurphy/issue_triage_sandbox"
  end

  test "subscribing to a repo" do
    triage_the_sandbox
    assert page.has_content?("issue_triage_sandbox")
  end

  test "listing subscribers" do
    triage_the_sandbox
    click_link 'issue_triage_sandbox'
    click_link 'Subscribers'
    assert page.has_content?("@mockstar")
  end

  test "list only favorite languages" do
    login_via_github
    visit "/"
    assert !page.has_content?("javascript")
  end
end
