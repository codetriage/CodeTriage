class PagesController < ApplicationController
  before_action :set_cache_headers, only: [:index]

  def index
    @repos = Repo.with_some_issues
    if language = valid_params[:language] || current_user.try(:favorite_languages)
      @repos = @repos.where(language: language)
    end
    @repos = @repos.order_by_issue_count.page(valid_params[:page]).per_page(valid_params[:per_page] || 50)

    if user_signed_in?
      @repos_subs = current_user.repo_subscriptions.page(valid_params[:page]).per_page(valid_params[:per_page] || 50).includes(:repo)
    end

    respond_to do |format|
      format.html {}
      format.json do
        htmlForPage = render_to_string(partial: "repos_with_pagination", locals: { repos: @repos }, formats: ['html'])
        render json: { html: htmlForPage }.to_json
      end
    end
  end

  def letsencrypt
    render text: "DkLDpTLqhJKCl6SL7jJVbFSxWOuFJwry0K3UN2bJmqk.YM5-pJAz5TdroNkLacqIn4LhTFEBP1lWeELIdWCckyk"
  end

  def letsencryptwww
    render text: "T2BMOklX7iIflqShN8o14d-mjsySpiy9jDKDD-oPquc.YM5-pJAz5TdroNkLacqIn4LhTFEBP1lWeELIdWCckyk"
  end

  def valid_params
    params.permit(:language, :per_page, :page)
  end

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
