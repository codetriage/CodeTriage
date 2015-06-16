class LanguageSubscriptionsController < ApplicationController
  before_filter :authenticate_user!

  def index
  end

  def create
    render plain: params[:language_subscription][:language]
  end

  def update
  end

  def destroy
  end

end
