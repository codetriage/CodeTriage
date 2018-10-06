# frozen_string_literal: true

class BackgroundInactiveEmailJob < ApplicationJob
  def perform(user)
    return false if user.repo_subscriptions.present?

    most_issues_repo = Repo.order_by_issue_count.first
    repo_in_need = Repo.order_by_need.not_in(most_issues_repo.id).first
    UserMailer.poke_inactive(
      user: user,
      most_issues_repo: most_issues_repo,
      repo_in_need: repo_in_need,
      random_repo: Repo.rand.not_in(most_issues_repo.id, repo_in_need.id).first
    ).deliver_later
  end
end
