module ReposHelper
  def link_to_or_log_in(options = {})
    path = user_signed_in? ? options[:path] : user_omniauth_authorize_path(:github, origin: request.fullpath)
    button_to options[:text], path, class: "button #{options[:html_class]}"
  end
end
