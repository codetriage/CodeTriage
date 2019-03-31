# frozen_string_literal: true

class BackgroundInactiveEmailJob < ApplicationJob
  def perform(user)
    return false if user.repo_subscriptions.exists?
    UserMailer.poke_inactive(user: user).deliver_later
  end
end
