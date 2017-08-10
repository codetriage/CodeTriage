require File.expand_path("../../../lib/sorted_repo_collection", __FILE__)

class ReposController < RepoBasedController

  before_action :authenticate_user!, only: [:new, :create, :edit, :update]
  before_action :default_format

  def new
    @repo = Repo.new(user_name: params[:user_name], name: name_from_params(params))
    @repo_sub = RepoSubscription.new
    if user_signed_in?
      @own_repos     = cached_repos 'repos', current_user.own_repos_json
      @starred_repos = cached_repos 'starred', current_user.starred_repos_json
      @watched_repos = cached_repos 'subscriptions', current_user.subscribed_repos_json
    end
  end

  def show
    @repo        = find_repo(params)
    @issues      = @repo.open_issues.order("created_at DESC").page(params[:page]).per_page(params[:per_page]||20)
    @docs        = @repo.doc_methods.order("created_at DESC").page(params[:page]).per_page(params[:per_page]||20)

    @repo_sub    = current_user.repo_subscriptions_for(@repo.id).first if current_user
    @subscribers = @repo.subscribers.public_profile.limit(27)
  end

  def create
    parse_params_for_repo_info
    @repo   = Repo.search_by(params[:repo][:name], params[:repo][:user_name]).first unless params_blank?
    @repo ||= Repo.new(repo_params)
    if @repo.save
      @repo_sub = current_user.repo_subscriptions.create(repo: @repo)
      flash[:notice] = "Added #{@repo.to_param} for triaging"
      SendSingleTriageEmailJob.perform_later(@repo_sub.id)
      redirect_to @repo
    else
      @own_repos = current_user.own_repos_json
      render :new
    end
  end

  def edit
    @repo = find_repo(params)
    redirect_to root_path, notice: "You cannot edit this repo" unless current_user.able_to_edit_repo?(@repo)
  end

  def update
    @repo = find_repo(params)
    if @repo.update_attributes(repo_params)
      redirect_to @repo, notice: "Repo updated"
    else
      render :edit
    end
  end

  private

    def default_format
      request.format = "html"
    end

    def repo_params
      params.require(:repo).permit(
        :notes,
        :name,
        :user_name,
        :issues_count,
        :stars_count,
        :language,
        :description,
        :full_name
      )
    end

    def parse_params_for_repo_info
      if params[:url]
        params[:url].match(/^https:\/\/github\.com\/([^\/]*)\/([^\/]*)\/?$/)
        params[:repo] ||= {}
        params[:repo][:user_name] = $1.to_s
        params[:repo][:name] = $2.to_s
      end
    end

    def params_blank?
      repo_params.blank?
    end

    def cached_repos(kind, repos_json)
      Rails.cache.fetch("user/#{kind}/#{current_user.id}", expires_in: 30.minutes) do
        SortedRepoCollection.new(repos_json)
      end
    end
end
