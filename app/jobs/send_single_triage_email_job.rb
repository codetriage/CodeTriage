class SendSingleTriageEmailJob < ApplicationJob
  def perform(id)
    repo_sub = RepoSubscription.includes(:user, :repo).find(id)
    IssueAssigner.new(repo_sub.user, [repo_sub]).assign!
    if assignment
      assignment.update!(delivered: true)
      UserMailer.send_triage(repo: repo_sub.repo, user: repo_sub.user, assignment: assignment).deliver_later
    end
  end

  private

  def assignment
    @assignment ||= repo_sub.user.issue_assignments.order(:created_at).eager_load(:repo_subscription)
                            .where(repo_subscriptions: { repo_id: repo_sub.repo_id }).last
  end
end
