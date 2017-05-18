class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action do
    if current_user && current_user.admin?
      Rack::MiniProfiler.authorize_request
    end
  end

  def authenticate_user!
    redirect_to user_github_omniauth_authorize_path(origin: request.fullpath) unless user_signed_in?
  end

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end
end
