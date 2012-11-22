class PagesController < ApplicationController
  def index
    @selected_lang = params[:lang] || "All"

    @repos = Repo.filter_by_language(@selected_lang).order_by_issue_count

	  @repos_subs = current_user.repo_subscriptions.page(params[:page]||1).per_page(params[:per_page]||50) if user_signed_in?
    @languages = Repo.languages
  end

  def show
    render "pages/show/#{params[:id]}"
  end
end
