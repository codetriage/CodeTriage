# frozen_string_literal: true

require "test_helper"

class DocGatingUiTest < ActionDispatch::IntegrationTest
  test "awaiting message shows for a Ruby repo with no doc subscribers" do
    visit repo_path(repos(:no_subscribers))
    assert_text "Doc suggestions turn on once this repo has an established subscriber"
  end

  test "paused message shows when doc subscribers exist but none are active" do
    # write_doc_only is a doc sub on issue_triage_sandbox with a nil docs_last_click_at.
    visit repo_path(repos(:issue_triage_sandbox))
    assert_text "Doc suggestions are paused"
  end

  test "a fresh account is told it cannot enable docs yet" do
    login_via_github # signs in mockstar
    users(:mockstar).update_column(:created_at, Time.current)

    visit repo_path(repos(:no_subscribers))
    assert_text "You can turn on docs once your account is 7 days old"
  end
end
