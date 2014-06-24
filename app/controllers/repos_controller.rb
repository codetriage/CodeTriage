require File.expand_path("../../../lib/sorted_repo_collection", __FILE__)

class ReposController < RepoBasedController

  def index
    @repos = Repo.order_by_subscribers.order(:name).page(params[:page]).per_page(params[:per_page] || 50)
  end

  def new
    @repo = Repo.new(user_name: params[:user_name], name: name_from_params(params))
    if user_signed_in?
      @own_repos = Rails.cache.fetch("user/repos/#{current_user.id}", expires_in: 30.minutes) do
        own_repos_response = GitHubBub.get("/user/repos", token: current_user.token, type: "owner", per_page: '100')
        SortedRepoCollection.new(own_repos_response.json_body)
      end

      @starred_repos = Rails.cache.fetch("users/starred/#{current_user.id}", expires_in: 30.minutes) do
        starred_repos_response = GitHubBub.get("/user/starred", token: current_user.token)
        SortedRepoCollection.new(starred_repos_response.json_body)
      end

      @watched_repos = Rails.cache.fetch("users/subscriptions/#{current_user.id}", expires_in: 30.minutes) do
        watched_repos_response = GitHubBub.get("/user/subscriptions", token: current_user.token)
        SortedRepoCollection.new(watched_repos_response.json_body)
      end
    end
  end

  def show
    @repo        = find_repo(params)
    @issues      = @repo.open_issues.order("created_at DESC").page(params[:page]).per_page(params[:per_page]||20)
    @repo_sub    = current_user.repo_subscriptions_for(@repo.id).first if current_user
    @subscribers = @repo.subscribers.public_profile.limit(27)
  end

  def create
    parse_params_for_repo_info
    @repo   = Repo.search_by(params[:repo][:name], params[:repo][:user_name]).first
    @repo ||= Repo.create!(repo_params)

    if @repo.save
      flash[:notice] = "Added #{@repo.to_param} for triaging"
      repo_sub = RepoSubscription.create(:repo => @repo, :user => current_user)
      RepoSubscription.background_send_triage_email(repo_sub.id)

      redirect_to @repo
    else
      response = GitHubBub.get("/user/repos", type: "owner", token: current_user.token)
      @own_repos = response.json_body
      render :new
    end
  end

  def edit
    @repo = find_repo(params)
    redirect_to root_path, :notice => "You cannot edit this repo" unless current_user.able_to_edit_repo?(@repo)
  end

  def update
    @repo = find_repo(params)
    if @repo.update_attributes(repo_params)
      redirect_to @repo, :notice => "Repo updated"
    else
      render :edit
    end
  end

  private

    def repo_params
      params.require(:repo).permit(
        :notes,
        :name,
        :user_name,
        :issues_count,
        :language,
        :description,
        :full_name
        )
    end

    def parse_params_for_repo_info
      if params[:url]
        params[:url].match(/^https:\/\/github\.com\/([^\/]*)\/([^\/]*)\/?$/)
        params[:repo] ||= {}
        params[:repo][:user_name] = $1
        params[:repo][:name] = $2
      end
    end
end
