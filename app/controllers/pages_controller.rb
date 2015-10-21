class PagesController < ApplicationController
  def index
    @repos = Repo.with_some_issues
    if language = valid_params[:language] || current_user.try(:favorite_languages)
      @repos = @repos.where(language: language)
    end
    @repos = @repos.order_by_issue_count.page(valid_params[:page]).per_page(valid_params[:per_page] || 50)

    if user_signed_in?
      @repos_subs = current_user.repo_subscriptions.page(valid_params[:page]).per_page( valid_params[:per_page] || 50).includes(:repo)
    end

    respond_to do |format|
      format.html { }
      format.json do
        htmlForPage = render_to_string(partial: "repos_with_pagination", locals: {repos: @repos}, formats: ['html'])
        render json: { html: htmlForPage }.to_json
      end
    end
  end

  def valid_params
    params.permit(:language, :per_page, :page)
  end
end
