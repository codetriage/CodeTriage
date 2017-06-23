class SendDailyTriageEmailJob < ApplicationJob
  def perform(user)
    return false if before_email_time_of_day?(user) || !user.repo_subscriptions.any? || skip_daily_email?(user)

    send_daily_triage!(user)
  end

  private

  def send_daily_triage!(user)
    assignments = user.issue_assignments_to_deliver
    send_email(user, assignments) if assignments.any?
  end

  def send_email(user, assignments)
    mail = UserMailer.send_daily_triage(user: user, assignments: assignments).deliver_now
    assignments.update_all(delivered: true)
    user.repo_subscriptions.update_all(last_sent_at: Time.now)
    mail
  end

  def skip_daily_email?(user)
    skip = email_decider(user).skip?(user.days_since_last_email)
    logger.debug "User #{user.github}: skip: #{skip.inspect}, days_since_last_clicked: #{user.days_since_last_clicked}, days_since_last_email: #{user.days_since_last_email}"
    skip
  end

  def email_decider(user)
    @email_decider ||= EmailDecider.new(user.days_since_last_clicked, minimum_frequency: user.email_frequency)
  end

  DEFAULT_EMAIL_TIME_OF_DAY = Time.utc(2000, 1, 1, 17, 00, 0)

  def before_email_time_of_day?(user)
    Time.current.change(year: 2000, month: 1, day: 1) < email_time_of_day_or_default(user)
  end

  def email_time_of_day_or_default(user)
    user.email_time_of_day || DEFAULT_EMAIL_TIME_OF_DAY
  end
end
