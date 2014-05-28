class IssueAssignmentsController < ApplicationController
  def create
    repo_sub = current_user.repo_subscriptions.find(params[:id])
    repo_sub.send_triage_email!
    redirect_to :back, notice: 'You will receive an email with your new issue shortly'
  end


  # get "/issue_assignments/:id/users/:user_id/click/:created_at", to: "issue_assignments#click"
  def click_redirect
    assignment = IssueAssignment.find(params[:id])
    if assignment.present? && assignment.user.id.to_s == params[:user_id]
      assignment.update_attributes(clicked: true)
      assignment.user.update_attributes(last_clicked_at: Time.now)
      redirect_to assignment.issue.html_url
    else
      redirect_to :root, message: "Bad url, if this problem persists please open an issue github.com/codetriage/codetriage"
    end
  end
end
