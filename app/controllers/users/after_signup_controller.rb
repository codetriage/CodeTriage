# frozen_string_literal: true

class Users::AfterSignupController < ApplicationController
  include Wicked::Wizard

  before_action :authenticate_user!

  steps :set_privacy

  def show
    @user = current_user
    render_wizard
  end

  def update
    @user = current_user
    @user.update(user_params)
    render_wizard @user
  end

  private

  def user_params
    params.require(:user).permit(
      :private,
      :email,
      :password,
      :password_confirmation,
      :remember_me,
      :zip,
      :phone_number,
      :twitter,
      :github,
      :github_access_token,
      :avatar_url,
      :name,
      :favorite_languages,
      :daily_issue_limit
    )
  end
end
