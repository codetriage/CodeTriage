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
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      triage_the_sandbox
      assert page.has_content?("issue_triage_sandbox")
    end
    assert_equal IssueAssignment.last.delivered, true
  end

  test "send an issue! button" do
    triage_the_sandbox
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      click_link "issue_triage_sandbox"
      click_link "Send new issue!"
      assert page.has_content?("You will receive an email with your new issue shortly")
    end
    assert_equal IssueAssignment.last.delivered, true
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
