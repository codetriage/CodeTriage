class UsersController < ApplicationController

  before_filter :authenticate_user!, :only => :update


  def show
    @user = User.find(params[:id])
  end

  def update
    @user = current_user
    @user.update_attributes(params[:user])
    render :edit
  end
end
