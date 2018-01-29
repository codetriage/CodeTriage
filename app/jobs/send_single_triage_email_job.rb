class SendSingleTriageEmailJob < ApplicationJob
  def perform(id, create: false)
    repo_sub = RepoSubscription.includes(:user, :repo).find(id)
    return unless repo_sub

    IssueAssigner.new(repo_sub.user, [repo_sub]).assign!
    if assignment(repo_sub)
      assignment.update!(delivered: true)
      UserMailer.send_triage(
        repo:       repo_sub.repo,
        user:       repo_sub.user,
        assignment: assignment,
        create:     create
      ).deliver_later
    end
  end

  private

  def assignment(repo_sub = nil)
    raise ArgumentError if repo_sub.nil? && @assignment.nil? # provide repo_sub first time
    @assignment ||= repo_sub.user.issue_assignments.order(:created_at).eager_load(:repo_subscription)
                            .where(repo_subscriptions: { repo_id: repo_sub.repo_id }).last
  end
end
