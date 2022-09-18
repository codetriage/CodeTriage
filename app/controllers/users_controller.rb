# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :omniauth_workaround_authenticate_user!, only: [:edit, :update, :destroy]

  def omniauth_workaround_authenticate_user!
    return if current_user

    # Omniauth changed the requirement so calling `authenticate_user!`
    # must be done through a post request, if someone tries
    # one of these actions that they must be logged in for
    # we have to tell them to log in first.
    if request.post?
      authenticate_user!
    else
      redirect_to user_path(id: params[:id]), alert: "Please log in to access your requested page"
    end
  end

  def show
    @user = User.find(params[:id])

    # You must be logged in to see your own user account, enforced in the view
    if @user.private?
      redirect_to root_path, alert: "User is private" unless current_user && @user == current_user
    end
  end

  def edit
    @user = current_user
  end

  def update
    begin
      uparams = user_params
    rescue ActionController::ParameterMissing
      uparams = { favorite_languages: [] }
    end

    @user = current_user
    if @user.update(uparams)
      redirect_to @user, flash: { success: 'User successfully updated' }
    end
  end

  def destroy
    @user = current_user
    @user.destroy
    redirect_to root_url, notice: "Successfully removed your user account"
  end

  def token_delete
    @user = User.find_by(account_delete_token: params[:account_delete_token])

    if @user.nil?
      redirect_to root_url, notice: "Account could not be found. You may have already deleted it, or your GitHub username may have changed."
    else
      @lonely_repos = @user.repos.where(subscribers_count: 0)
    end
  end

  def token_destroy
    @user = User.find_by!(account_delete_token: params[:account_delete_token])
    @user.destroy
    redirect_to root_url, notice: "Successfully removed your user account"
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
      :daily_issue_limit,
      :email_frequency,
      :email_time_of_day,
      :skip_issues_with_pr,
      :htos_contributor_unsubscribe,
      favorite_languages: []
    )
  end
end
