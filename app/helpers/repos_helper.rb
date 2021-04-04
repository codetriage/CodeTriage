# frozen_string_literal: true

module ReposHelper
  def link_to_or_log_in(options = {})
    path = user_signed_in? ? options[:path] : user_github_omniauth_authorize_path(origin: request.fullpath)
    button_to options[:text], path, class: "button #{options[:html_class]}", method: :post
  end
end
