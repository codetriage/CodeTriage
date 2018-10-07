# frozen_string_literal: true

class BackgroundInactiveEmailJob < ApplicationJob
  def perform(user)
    return false if user.repo_subscriptions.present?

    with_most_issues = curated_repos_for(user).order_by_issue_count.first
    in_need = curated_repos_for(user).order_by_need.not_in(with_most_issues.id).first
    random = curated_repos_for(user).rand.not_in(with_most_issues.id, in_need.id).first

    UserMailer.poke_inactive(
      user: user,
      most_issues_repo: with_most_issues,
      repo_in_need: in_need,
      random_repo: random
    ).deliver_later
  end

  private

  def curated_repos_for(user)
    Repo.select(:id, :full_name).in_user_lang_preferences(user)
  end
end
