class PagesController < ApplicationController
  before_action :set_cache_headers, only: [:index]

  # Renders the about page view
  def what
    render "what"
  end

  def privacy
    render "privacy"
  end

  def support
    render "support"
  end

  def index
    set_title("Get Started Contributing to Open Source Projects")
    set_description(description)

    @repos = Repo.with_some_issues
                 .select(:id, :updated_at, :issues_count, :language, :full_name, :name, :description)
    if (language = valid_params[:language] || current_user.try(:favorite_languages))
      @repos = @repos.where(language: language)
    end
    @repos = @repos.without_user_subscriptions(current_user.id) if user_signed_in?
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

  private

  def description
    Rails.cache.fetch("pages#index/description", expires_in: 1.hour) do
      "Discover the easiest way to get started contributing to open source. " \
      "Over #{number_with_delimiter(User.count, delimiter: ',')} devs are " \
      "helping #{number_with_delimiter(Repo.count, delimiter: ',')} projects " \
      "with our free, community developed tools"
    end
  end

  def valid_params
    params.permit(:language, :per_page, :page)
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
