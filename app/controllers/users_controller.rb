class UsersController < ApplicationController

  before_filter :authenticate_user!, :only => [:update, :destroy]

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
    @user = current_user
    @user.update_attributes(user_params)
    if @user.save!
      redirect_to @user, :flash => { :success => 'User successfully updated' }
    end
  end

  def destroy
    @user = current_user
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
        favorite_languages: []
        )
    end
end
