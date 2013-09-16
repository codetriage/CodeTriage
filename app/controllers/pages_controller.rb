class PagesController < ApplicationController

  layout :get_layout

  def index
    @repos = Repo.repos_needing_help_for_user(current_user)
    @repos_subs = current_user.repo_subscriptions.page(params[:page]||1).per_page(params[:per_page]||50) if user_signed_in?
  end

  private

  def get_layout
    params[:action] == 'index' ? 'home' : 'application'
  end
end
