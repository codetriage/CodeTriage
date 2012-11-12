class UserMailer < ActionMailer::Base
  default from: "Issue Triage <noreply@issuetriage.heroku.com>"


  def send_triage(options = {})
    @user   = options[:user]
    @repo   = options[:repo]
    @issue  = options[:issue]
    mail(:to => @user.email, :reply_to => "noreply@codetriage.com", :subject => "Help Triage #{@repo.path} on Github")
  end

  def poke_inactive(user)
    @user         = user
    @most_repo   = Repo.order_by_issue_count.first
    @need_repo   = Repo.order_by_need.not_in(@most_repo.id).first
    @random_repo = Repo.rand.not_in(@most_repo.id, @need_repo.id).first
    mail(:to => @user.email, :reply_to => "noreply@codetriage.com", :subject => "Code Triage misses you")
  end


  class Preview < MailView
    # Pull data from existing fixtures
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
