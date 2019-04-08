class UserMailer < ActionMailer::Base
  include ActionView::Helpers::DateHelper
  default from: "CodeTriage <noreply@codetriage.com>"

  layout "mail_layout"

  def send_daily_triage(
      user_id:,
      assignment_ids:,
      email_at:,
      read_doc_ids: [],
      write_doc_ids: []
    )

    user = User.find(user_id)
    return unless set_and_check_user(user)

    email_at = DateTime.parse(email_at)
    if user.last_email_at.nil? || user.last_email_at < email_at
      user.raw_emails_since_click += 1
      user.last_email_at = email_at
      user.save!
    end

    @grouped_issues_docs = MailBuilder::GroupedIssuesDocs.new(
      user_id: user_id,
      assignment_ids: assignment_ids,
      read_doc_ids: read_doc_ids,
      write_doc_ids: write_doc_ids
    )

    subject = String.new
    if user.effective_streak_count.zero?
      subject << "[Start contributing today 💌]"
    else
      subject << "[Grow your streak #{user. effective_streak_count} 💌]"
    end

    subject << " " unless subject.end_with?(" ")

    if @grouped_issues_docs.any_issues
      subject << "Help Triage #{assignment_ids.size} Open Source #{"Issue".pluralize(assignment_ids.size)}"
    else
      doc_size = read_doc_ids.length + write_doc_ids.length
      subject << "Help Triage #{doc_size} Open Source #{"Doc".pluralize(doc_size)}"
    end

    mail(
      to: @user.email,
      reply_to: "noreply@codetriage.com",
      subject: subject
    )
  end

  def daily_docs(user:, write_docs:, read_docs:)
    return unless set_and_check_user(user)
    @write_docs = write_docs
    @read_docs  = read_docs
    count       = (@write_docs.try(:count) || 0) + (@read_docs.try(:count) || 0)
    subject     = "Check out #{count} Open Source #{"Doc".pluralize(count)}"
    mail(to: @user.email, subject: subject)
  end

  def send_triage(user:, assignment:, repo:, create: false)
    return unless set_and_check_user(user)
    @create = create
    @repo  = repo
    @issue = assignment.issue
    mail(to: @user.email, reply_to: "noreply@codetriage.com", subject: "[CodeTriage] Help triage #{@repo.full_name}")
  end

  def poke_inactive(user:)
    return unless set_and_check_user(user)
    @most_repo   = Repo.order_by_issue_count.first
    @need_repo   = Repo.order_by_need.not_in(@most_repo.id).first
    @random_repo = Repo.rand.not_in(@most_repo.id, @need_repo.id).first || @most_repo || @need_repo
    mail(to: @user.email, reply_to: "noreply@codetriage.com", subject: "CodeTriage misses you")
  end

  def invalid_token(user:)
    return unless set_and_check_user(user)
    mail(to: @user.email, reply_to: "noreply@codetriage.com", subject: "CodeTriage auth failure")
  end

  # general purpose mailer for sending out admin communications, only use from one off tasks
  def spam(user:, subject:, message:)
    return unless set_and_check_user(user)
    @message = message
    mail(to: @user.email, reply_to: "noreply@codetriage.com", subject: subject)
  end

  private def set_and_check_user(user)
    @user = user
    !@user.email.blank?
  end
end
