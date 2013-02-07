class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def github
    @user = User.find_for_github_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "GitHub"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.github_data"] = request.env["omniauth.auth"].delete("extra")
      flash[:error] = no_email_error if request.env["omniauth.auth"].info.email.blank?
      redirect_to root_path
    end
  end

  private

  def no_email_error
    msg =  "You need a public email address on GitHub to sign up"
    msg << "you can add an email, sign up for triage, then remove it from GitHub:<hr />"
    msg << "<a href='https://github.com/settings/profile'>GitHub Profile</a>"
    msg.html_safe
  end
end
