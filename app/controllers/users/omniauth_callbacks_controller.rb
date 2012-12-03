class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def github
    @user = User.find_for_github_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Github"
      sign_in_and_redirect @user, :event => :authentication
    else
      flash[:error] = no_email_error if request.env["omniauth.auth"].info.email.blank?
      redirect_to root_path
    end
  end

  private

  def no_email_error
    msg =  "You need a public email address on Github to sign up"
    msg << "you can add an email, sign up for triage, then remove it from Github:<hr />"
    msg << "<a href='https://github.com/settings/profile'>Github Profile</a>"
    msg.html_safe
  end
end
