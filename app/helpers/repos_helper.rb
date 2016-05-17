module ReposHelper
  def wanna_triage_button(repo, html_class: "")
    path = user_signed_in? ? repo_subscriptions_path(repo_id: repo.id) : user_omniauth_authorize_path(:github, origin: request.fullpath)
    button_to "I Want to Triage #{repo.path}", path, class: "button #{html_class}"
  end
end
