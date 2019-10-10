# frozen_string_literal: true

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
      assignment.update(clicked: true)
      assignment.user.update(last_clicked_at: Time.now)
      redirect_to assignment.issue.html_url
    else
      redirect_to :root, message: "Bad url, if this problem persists please open an issue github.com/codetriage/codetriage"
    end
  end
end
