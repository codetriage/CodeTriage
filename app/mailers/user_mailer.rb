require 'rails_autolink'

class UserMailer < ActionMailer::Base
  default from: "CodeTriage <noreply@codetriage.com>"

  def send_daily_triage(options = {})
    @user        = options[:user]
    @assignments = options[:assignments]
    @max_days    = 2
    subject = ""
    @days   = @user.days_since_last_click
    subject << "[#{@days} days] " if @days > @max_days
    subject << "Help Triage #{@assignments.count} Open Source #{"Issue".pluralize(@assignments.count)}"
    mail(:to => @user.email, reply_to: "noreply@codetriage.com", subject: subject)
  end


  def send_triage(options = {})
    raise "no assignment" unless assignment =  options[:assignment]
    @user  = options[:user]
    @repo  = options[:repo]
    @issue = assignment.issue
    mail(:to => @user.email, reply_to: "noreply@codetriage.com", subject: "Help Triage #{@repo.path} on GitHub")
  end

  def poke_inactive(user)
    @user        = user
    @most_repo   = Repo.order_by_issue_count.first
    @need_repo   = Repo.order_by_need.not_in(@most_repo.id).first
    @random_repo = Repo.rand.not_in(@most_repo.id, @need_repo.id).first
    mail(:to => @user.email, reply_to: "noreply@codetriage.com", subject: "Code Triage misses you")
  end

  def invalid_token(user)
    @user = user
    mail(to: @user.email, reply_to: "noreply@codetriage.com", subject: "Code Triage auth failure")
  end


  # general purpose mailer for sending out admin communications, only use from one off tasks
  def spam(user, options = {})
    @user    = user
    @message = options[:message]
    mail(:to => @user.email, reply_to: "noreply@codetriage.com", subject: options[:subject])
  end

  class Preview < MailView

    def invalid_token
      user = User.last
      ::UserMailer.invalid_token(user)
    end

    # Pull data from existing fixtures
    def send_spam
      user    = User.last
      message = "Hey, we just launched something big http://google.com"
      subject = "Big launch"
      ::UserMailer.spam(user, message: message, subject: subject)
    end

    def send_triage
      user  = User.last
      repo  = Repo.order("random()").first
      issue = Issue.where(state: "open", repo_id: repo.id).where("number is not null").first!
      sub   = RepoSubscription.first_or_create!(user_id: user.id, repo_id: repo.id)
      assignment = sub.issue_assignments.first_or_create!(issue_id: issue.id)
      ::UserMailer.send_triage(:user => user, :repo => repo, :assignment => assignment)
    end

    def send_daily_triage
      user        = User.last
      assignments = []
      rand(1..5).times do
        repo  = Repo.order("random()").first
        issue = Issue.where(state: "open", repo_id: repo.id).where("number is not null").first
        sub   = RepoSubscription.first_or_create!(user_id: user.id, repo_id: repo.id)
        assignments << sub.issue_assignments.first_or_create!(issue_id: issue.id)
      end
      ::UserMailer.send_daily_triage(user: user, assignments: assignments)
    end

    def poke_inactive
      user = User.last
      ::UserMailer.poke_inactive(user)
    end
  end

end
