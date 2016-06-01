module ReposHelper
  def link_to_or_log_in(text: text, path: path, html_class: "")
    path = user_signed_in? ? path : user_omniauth_authorize_path(:github, origin: request.fullpath)
    button_to text, path, class: "button #{html_class}"
  end
end
