class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update, :destroy]

  def show
    @user = User.find(params[:id])
    if @user.private?
      redirect_to root_path unless current_user && @user == current_user
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
    if @user.update_attributes(uparams)
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
      favorite_languages: []
    )
  end
end
