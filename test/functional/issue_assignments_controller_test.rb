require 'test_helper'

class IssueAssignmentsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    sign_in users(:schneems)
  end

  test '#create redirects when the user request a new issue' do
    repo_sub = repo_subscriptions(:schneems_to_triage)

    post :create, params: { id: repo_sub.id }

    assert_redirected_to repo_path(repo_sub.repo.full_name)
  end

  test '#click_issue_redirect redirects user when assignment matches the user id' do
    user = users(:schneems)
    assignment = issue_assignments(:schneems_triage_issue_assignment)

    get :click_issue_redirect, params: { id: assignment.id, user_id: user.id }

    assert_redirected_to assignment.issue.html_url
  end

  test '#click_issue_redirect redirects to error when there is a bad url' do
    assignment = issue_assignments(:schneems_triage_issue_assignment)

    get :click_issue_redirect, params: { id: assignment.id, user_id: 42 }

    assert_redirected_to :root
  end
end
