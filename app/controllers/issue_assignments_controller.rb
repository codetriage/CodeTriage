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
      redirect_to assignment.issue.html_url
    else
      redirect_to :root, message: "Bad url, if this problem persists please open an issue github.com/codetriage/codetriage"
    end
  end

  def jump_to_issue
    if IssueAssignment.where(repo_subscription_id: params[:repo_sub_id]).any?
      issue_assignment = IssueAssignment.where(repo_subscription_id: params[:repo_sub_id]).sample
      issue_assignment.user.record_click!
      issue_assignment.update_attributes(clicked: true)
      issue_assignment.user.update_attributes(last_clicked_at: Time.now)
      redirect_to issue_assignment.issue.html_url
    else
      redirect :root, message: "Something went wrong"
    end
  end
end
