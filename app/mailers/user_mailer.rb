class UserMailer < ActionMailer::Base
  default from: "Issue Triage <noreply@issuetriage.heroku.com>"


  def send_triage(options = {})
    @user   = options[:user]
    @repo   = options[:repo]
    @issue  = options[:issue]
    mail(:to => @user.email, :reply_to => "noreply", :subject => "Help Triage #{@repo.path} on Github")
  end


  class Preview < MailView
    # Pull data from existing fixtures
    def send_triage
      user  = User.last
      repo  = Repo.last
      issue = Issue.where(state: "open").last
      ::UserMailer.send_triage(:user => user, :repo => repo, :issue => issue)
    end
  end

end
