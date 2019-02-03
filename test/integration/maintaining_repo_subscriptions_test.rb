require "test_helper"

class MaintainingRepoSubscriptionsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  fixtures :repos

  def triage_the_sandbox
    login_via_github
    visit "/"
    click_link "issue_triage_sandbox"

    first(:button, "Triage Issues").click

    assert page.has_content?("You'll receive daily triage e-mails for this repository.")
  end

  test "subscribing to a repo" do
    assert_enqueued_jobs 1, only: SendSingleTriageEmailJob do
      triage_the_sandbox
      assert page.has_content?("issue_triage_sandbox")
    end
  end

  test "send an issue! button" do
    triage_the_sandbox
    assert_enqueued_jobs 1, only: SendSingleTriageEmailJob do
      click_link "Send me a new issue!"
      assert page.has_content?("You will receive an email with your new issue shortly")
    end
  end

  test "listing subscribers" do
    triage_the_sandbox
    assert page.has_content?("mockstar")
  end

  test "clicking an issue leads to a github page" do
    triage_the_sandbox
    assert page.has_link?("first test issue", href: /github.com/)
  end

  test "clicking a doc leads to doc_methods" do
    triage_the_sandbox
    click_link "/path/here/issue_triage"
    assert page.has_current_path?(/doc_methods/)
  end

  # test "list only favorite languages" do
  #   login_via_github
  #   visit "/"
  #   assert !page.has_content?("javascript")
  # end
end
