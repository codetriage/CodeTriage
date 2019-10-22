# frozen_string_literal: true

class BackgroundInactiveEmailJob < ApplicationJob
  def perform(user_or_id, repos_by_need_ids:)
    if user_or_id.is_a?(Integer)
      user = User.find(user_or_id)
    else
      user = user_or_id
    end

    return false if user.repo_subscriptions.present?

    UserMailer.poke_inactive(user: user, repos_by_need_ids: repos_by_need_ids).deliver_now
  end
end
