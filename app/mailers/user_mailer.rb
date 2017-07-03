require 'rails_autolink'

class UserMailer < ActionMailer::Base
  include ActionView::Helpers::DateHelper
  default from: "CodeTriage <noreply@codetriage.com>"
  before_action :set_user,
                :abort_if_no_email

  def send_daily_triage(user:, assignments:)
    @assignments = assignments
    @max_days    = 2
    subject = ""
    @days   = @user.days_since_last_clicked
    subject << "[#{ time_ago_in_words(@days.days.ago).humanize }] " if @days > @max_days
    subject << "Help Triage #{@assignments.size} Open Source #{"Issue".pluralize(@assignments.size)}"
    mail(to: @user.email, reply_to: "noreply@codetriage.com", subject: subject)
  end

  def daily_docs(user:, write_docs:, read_docs:)
    @write_docs = write_docs
    @read_docs  = read_docs
    count       = (@write_docs.try(:count) || 0) + (@read_docs.try(:count) || 0)
    subject     = "Check out #{count} Open Source #{"Doc".pluralize(count)}"
    mail(to: @user.email, subject: subject)
  end

  def send_triage(user:, assignment:, repo:)
    @repo  = repo
    @issue = assignment.issue
    mail(to: @user.email, reply_to: "noreply@codetriage.com", subject: "Help Triage #{@repo.path} on GitHub")
  end

  def poke_inactive(user:)
    @most_repo   = Repo.order_by_issue_count.first
    @need_repo   = Repo.order_by_need.not_in(@most_repo.id).first
    @random_repo = Repo.rand.not_in(@most_repo.id, @need_repo.id).first
    mail(to: @user.email, reply_to: "noreply@codetriage.com", subject: "Code Triage misses you")
  end

  def invalid_token(user:)
    mail(to: @user.email, reply_to: "noreply@codetriage.com", subject: "Code Triage auth failure")
  end

  # general purpose mailer for sending out admin communications, only use from one off tasks
  def spam(user:, message:)
    mail(to: @user.email, reply_to: "noreply@codetriage.com", subject: options[:subject])
  end

  class Preview < MailView

    def invalid_token
      user = User.last
      ::UserMailer.invalid_token(user: user)
    end

    # Pull data from existing fixtures
    def send_spam
      user    = User.last
      message = "Hey, we just launched something big http://google.com"
      subject = "Big launch"
      ::UserMailer.spam(user: user, message: message, subject: subject)
    end

    def send_triage
      user  = User.last
      repo  = Repo.order("random()").first
      issue = Issue.where(state: "open", repo_id: repo.id).where.not(number: nil).first!
      sub   = RepoSubscription.first_or_create!(user_id: user.id, repo_id: repo.id)
      assignment = sub.issue_assignments.first_or_create!(issue_id: issue.id)
      ::UserMailer.send_triage(user: user, repo: repo, assignment: assignment)
    end

    def send_daily_triage
      user        = User.last
      assignments = []
      rand(1..5).times do
        repo  = Repo.order("random()").first
        issue = Issue.where(state: "open", repo_id: repo.id).where.not(number: nil).first
        sub   = RepoSubscription.first_or_create!(user_id: user.id, repo_id: repo.id)
        assignments << sub.issue_assignments.first_or_create!(issue_id: issue.id)
      end
      ::UserMailer.send_daily_triage(user: user, assignments: assignments)
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

      ::UserMailer.daily_docs(user: user, write_docs: write_docs, read_docs: read_docs)
    end
  end

  private

  def set_user
    @user = user
  end

  def abort_if_no_email
    return false if user.email.blank?
  end
end
