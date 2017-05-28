class BackgroundInactiveEmailJob < ApplicationJob
  def perform(user)
    return false if user.repo_subscriptions.present?
    UserMailer.poke_inactive(user).deliver_now
  end
end
