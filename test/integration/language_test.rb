require "test_helper"

class LanguageTest < ActionDispatch::IntegrationTest
  fixtures :users, :repos

  def triage_ruby
    login_via_github
    visit "/"
    click_link "ruby"
    click_button "Subscribe to this Language"
  end

  test "subscribing to a language" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      triage_ruby
      assert page.has_content?("Awesome! You'll receive daily triage e-mails for this language.")
    end
    assert_equal IssueAssignment.last.delivered, true
  end

  test "send an issue! button" do
    triage_ruby
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      click_link "ruby"
      click_link "Send a random issue!"
      assert page.has_content?("You will receive an email with your new issue shortly")
    end
    assert_equal IssueAssignment.last.delivered, true
  end

end
