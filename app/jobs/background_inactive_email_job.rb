# frozen_string_literal: true

class BackgroundInactiveEmailJob < ApplicationJob
  def perform(user, repos_by_need_ids: repos_by_need_ids)
    return false if user.repo_subscriptions.present?
    UserMailer.poke_inactive(user: user, repos_by_need_ids: repos_by_need_ids).deliver_later
  end
end
