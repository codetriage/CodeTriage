class UsersController < ApplicationController

  before_filter :authenticate_user!, :only => [:update, :destroy]


  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = current_user
    @user.update_attributes(params[:user])
    redirect_to :back
  end

  def destroy
    @user = current_user
    @user.destroy
    redirect_to root_url
  end
end
