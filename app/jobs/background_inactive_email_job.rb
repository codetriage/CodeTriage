# frozen_string_literal: true

class BackgroundInactiveEmailJob < ApplicationJob
  def perform(user)
    return false if user.repo_subscriptions.present?
    UserMailer.poke_inactive(user: user).deliver_later
  end
end
