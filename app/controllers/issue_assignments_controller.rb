class IssueAssignmentsController < ApplicationController
  def create
    repo_sub = current_user.repo_subscriptions.find(params[:id])
    repo_sub.send_triage_email!
    redirect_to :back, notice: 'You will receive an email with your new issue shortly'
  end
end
