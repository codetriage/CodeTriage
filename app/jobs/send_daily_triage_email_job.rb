# frozen_string_literal: true

class SendDailyTriageEmailJob < UserBasedJob
  def perform(user, force_send: false)
    return false if !force_send && skip?(user)

    send_daily_triage!(user)
  end

  private

  def reason_for_skip(user)
    return "Not time to send" if before_email_time_of_day?(user)
    return "No subscriptions" if user.repo_subscriptions.empty?
    return "Sent email within 24 hours" if email_sent_today?(user)
    return "Email backoff" if skip_daily_email?(user)
    false
  end

  def skip?(user)
    reason_for_skip(user)
  end

  def send_daily_triage!(user)
    assignments = user.issue_assignments_to_deliver
    subscriptions = user.repo_subscriptions.order(Arel.sql("RANDOM()")).includes(:doc_assignments).load
    docs = DocMailerMaker.new(user, subscriptions)

    return if assignments.empty? && docs.empty?
    send_email(
      user: user,
      assignments: assignments,
      docs: docs
    )
  end

  def send_email(user:, assignments:, docs:)
    mail = UserMailer.send_daily_triage(
      user_id: user.id,
      assignment_ids: assignments.pluck(:id),
      write_doc_ids: docs.write_docs.map(&:id),
      read_doc_ids: docs.read_docs.map(&:id),
      email_at: Time.now.iso8601
    ).deliver_later

    assignments.update_all(delivered: true)
    user.repo_subscriptions.update_all(last_sent_at: Time.now)
    mail
  end

  def email_sent_today?(user)
    user.repo_subscriptions.where("last_sent_at >= ?", Time.current.beginning_of_day).any?
  end

  def skip_daily_email?(user)
    skip = email_decider(user).skip?(user.days_since_last_email)
    logger.debug "User #{user.github}: skip: #{skip.inspect}, days_since_last_clicked: #{user.days_since_last_clicked}, days_since_last_email: #{user.days_since_last_email}"
    skip
  end

  def email_decider(user)
    EmailRateLimit.new(user.days_since_last_clicked, minimum_frequency: user.email_frequency)
  end

  DEFAULT_EMAIL_TIME_OF_DAY = Time.utc(2000, 1, 1, 17, 0o0, 0)

  def before_email_time_of_day?(user)
    Time.current.change(year: 2000, month: 1, day: 1) < email_time_of_day_or_default(user)
  end

  def email_time_of_day_or_default(user)
    user.email_time_of_day || DEFAULT_EMAIL_TIME_OF_DAY
  end
end
