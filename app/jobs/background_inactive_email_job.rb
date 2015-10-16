class BackgroundInactiveEmailJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    user = User.find(id.to_i)
    return false if user.repo_subscriptions.present?
    UserMailer.poke_inactive(user).deliver_now
  end
end
