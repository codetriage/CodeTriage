module ReposHelper
  def wanna_triage_button(repo, html_class: "")
    path = user_signed_in? ? repo_subscriptions_path( repo_subscription: { repo_id: repo.id } ) : user_omniauth_authorize_path(:github, origin: request.fullpath)
    button_to "Triage Issues", path, class: "button #{html_class}"
  end
end
