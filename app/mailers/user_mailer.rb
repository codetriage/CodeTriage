require 'rails_autolink'

class UserMailer < ActionMailer::Base
  default from: "Issue Triage <noreply@issuetriage.heroku.com>"


  def send_triage(options = {})
    @user    = options[:user]
    @repos   = options[:issues].map { |issue| issue.repo }
    @issues  = options[:issues]
    repos    = @repos.map(&:path).join ', '
    mail(:to => @user.email, reply_to: "noreply@codetriage.com", subject: "Help Triage #{repos} on GitHub")
  end

  def poke_inactive(user)
    @user         = user
    @most_repo   = Repo.order_by_issue_count.first
    @need_repo   = Repo.order_by_need.not_in(@most_repo.id).first
    @random_repo = Repo.rand.not_in(@most_repo.id, @need_repo.id).first
    mail(:to => @user.email, reply_to: "noreply@codetriage.com", subject: "Code Triage misses you")
  end


  # general purpose mailer for sending out admin communications, only use from one off tasks
  def spam(user, options = {})
    @user    = user
    @message = options[:message]
    mail(:to => @user.email, reply_to: "noreply@codetriage.com", subject: options[:subject])
  end

  class Preview < MailView
    # Pull data from existing fixtures
    def send_spam
      user    = User.last
      message = "Hey, we just launched something big http://google.com"
      subject = "Big launch"
      ::UserMailer.spam(user, message: message, subject: subject)
    end

    def send_triage
      user  = User.last
      repo  = Repo.last
      issue = Issue.where(state: "open").where("number is not null").last
      ::UserMailer.send_triage(:user => user, :repo => repo, :issue => issue)
    end

    def poke_inactive
      user = User.last
      ::UserMailer.poke_inactive(user)
    end
  end

end
