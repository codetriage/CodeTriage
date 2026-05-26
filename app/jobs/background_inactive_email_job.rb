# frozen_string_literal: true

class BackgroundInactiveEmailJob < UserBasedJob
  def perform(user, min_issue_count:, min_subscriber_count:)
    return false if user.repo_subscriptions.present?

    UserMailer.poke_inactive(user: user, min_issue_count: min_issue_count, min_subscriber_count: min_subscriber_count).deliver_now
  end
end
