class IssueAssignmentsController < ApplicationController
  def create
    repo_sub = current_user.repo_subscriptions.find(params[:id])
    SendSingleTriageEmailJob.perform_later(repo_sub.id)
    redirect_to repo_path(repo_sub.repo), notice: 'You will receive an email with your new issue shortly'
  end

  # get "/issue_assignments/:id/users/:user_id/click/:created_at", to: "issue_assignments#click"
  def click_issue_redirect
    assignment = IssueAssignment.find(params[:id])
    if assignment&.user&.id.to_s == params[:user_id]
      assignment.user.record_click!
      assignment.update_attributes(clicked: true)
      assignment.user.update_attributes(last_clicked_at: Time.now)
      issue_html_url = parsed_url(assignment.issue.html_url)
      redirect_to issue_html_url if issue_html_url
      redirect_to_root_with_message
    else
      redirect_to_root_with_message
    end
  end

  private

  def redirect_to_root_with_message
    redirect_to :root, message: "Bad url, if this problem persists please open an issue github.com/codetriage/codetriage"
  end
end
