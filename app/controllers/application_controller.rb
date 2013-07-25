class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_in_path_for(resource)
    if !resource.valid_email?
      edit_user_path(resource)
    elsif resource.new_record?
      users_after_signup_index_path
    else
      request.env['omniauth.origin'] || stored_location_for(resource) || root_path
    end
  end
end
