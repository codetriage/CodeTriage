require 'rails_autolink'

class UserMailer < ActionMailer::Base
  include ActionView::Helpers::DateHelper
  default from: "CodeTriage <noreply@codetriage.com>"

  layout "mail_layout"

  def send_daily_triage(
      user_id:,
      assignment_ids:,
      read_doc_ids: [],
      write_doc_ids: []
  )

    user = User.find(user_id)
    return unless set_and_check_user(user)

    @grouped_issues_docs = MailBuilder::GroupedIssuesDocs.new(
      user_id:        user_id,
      assignment_ids: assignment_ids,
      read_doc_ids:   read_doc_ids,
      write_doc_ids:  write_doc_ids
    )

    @max_days = 2
    subject   = ""
    @days     = @user.days_since_last_clicked
    subject   << "[#{time_ago_in_words(@days.days.ago).humanize}] " if @days > @max_days

    if @grouped_issues_docs.any_issues
      subject << "Help Triage #{assignment_ids.size} Open Source #{"Issue".pluralize(assignment_ids.size)}"
    else
      doc_size = read_doc_ids.length + write_doc_ids.length
      subject << "Help Triage #{doc_size} Open Source #{"Doc".pluralize(doc_size)}"
    end

    mail(
      to:       @user.email,
      reply_to: "noreply@codetriage.com",
      subject:  subject
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
    @random_repo = Repo.rand.not_in(@most_repo.id, @need_repo.id).first
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

  class Preview < MailView
    def invalid_token
      user = User.last
      ::UserMailer.invalid_token(user: user)
    end

    # Pull data from existing fixtures
    def send_spam
      user    = User.last
      subject = "Big launch"
      message = "hello world"
      ::UserMailer.spam(user: user, subject: subject, message: message)
    end

    def send_triage_create
      user  = User.last
      repo  = Repo.order("random()").first
      issue = Issue.where(state: "open", repo_id: repo.id).where.not(number: nil).first!
      sub   = RepoSubscription.where(user_id: user.id, repo_id: repo.id).first_or_create!
      assignment = sub.issue_assignments.where(issue_id: issue.id).first_or_create!
      ::UserMailer.send_triage(user: user, repo: repo, assignment: assignment, create: true)
    end

    def send_triage
      user  = User.last
      repo  = Repo.order("random()").first
      issue = Issue.where(state: "open", repo_id: repo.id).where.not(number: nil).first!
      sub   = RepoSubscription.where(user_id: user.id, repo_id: repo.id).first_or_create!
      assignment = sub.issue_assignments.where(issue_id: issue.id).first_or_create!
      ::UserMailer.send_triage(user: user, repo: repo, assignment: assignment)
    end

    def send_daily_triage_mixed
      write_docs = DocMethod.order("RANDOM()").includes(:repo).missing_docs.first(rand(0..8))
      read_docs  = DocMethod.order("RANDOM()").includes(:repo).with_docs.first(rand(0..8))

      write_docs = DocMethod.order("RANDOM()").includes(:repo).first(rand(0..8)) if write_docs.blank?
      read_docs  = DocMethod.order("RANDOM()").includes(:repo).first(rand(0..8)) if read_docs.blank?

      user        = User.last
      assignments = []
      repos       = (write_docs + read_docs).map(&:repo)

      (write_docs + read_docs).each do |doc|
        RepoSubscription.where(
          user_id: user.id,
          repo_id: doc.repo.id
        ).first_or_create!
      end

      repos.each do |repo|
        issue_count = rand(3..5)
        issue_count.times.each do
          issue = Issue.where(state: "open", repo_id: repo.id).where.not(number: nil).first
          next if issue.nil?

          sub = RepoSubscription.where(
            user_id: user.id,
            repo_id: repo.id
          ).first_or_create!
          assignment = sub.issue_assignments.where(issue_id: issue.id).first_or_create!
          assignments << assignment
        end
      end

      ::UserMailer.send_daily_triage(
        user_id:        user.id,
        assignment_ids: assignments.map(&:id),
        write_doc_ids:  write_docs.map(&:id),
        read_doc_ids:   read_docs.map(&:id)
      )
    end

    def send_daily_triage_issues_only
      issue_count = rand(3..5)
      user        = User.last
      assignments = []

      issue_count.times.each do
        issue = Issue
                .where(state: "open")
                .where.not(number: nil)
                .order("RANDOM()")
                .first

        next if issue.nil?

        sub        = RepoSubscription.where(user_id: user.id, repo_id: issue.repo.id).first_or_create!
        assignment = sub.issue_assignments.where(issue_id: issue.id).first_or_create!
        assignments << assignment
      end

      ::UserMailer.send_daily_triage(
        user_id:        user.id,
        assignment_ids: assignments.map(&:id)
      )
    end

    def poke_inactive
      user = User.last
      ::UserMailer.poke_inactive(user: user)
    end

    def daily_docs
      user       = User.last

      write_docs = DocMethod.order("RANDOM()").missing_docs.first(rand(0..8))
      read_docs  = DocMethod.order("RANDOM()").with_docs.first(rand(0..8))

      write_docs = DocMethod.order("RANDOM()").first(rand(0..8)) if write_docs.blank?
      read_docs  = DocMethod.order("RANDOM()").first(rand(0..8)) if read_docs.blank?

      ::UserMailer.daily_docs(
        user:       user,
        write_docs: write_docs,
        read_docs:  read_docs
      )
    end
  end

  private

  def set_and_check_user(user)
    @user = user
    !@user.email.blank?
  end
end
