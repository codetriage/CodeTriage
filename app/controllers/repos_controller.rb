require File.expand_path("../../../lib/sorted_repo_collection", __FILE__)

class ReposController < RepoBasedController

  before_filter :authenticate_user!, only: [:new, :create, :edit, :update]

  def new
    @repo = Repo.new(user_name: params[:user_name], name: name_from_params(params))
    @repo_sub = RepoSubscription.new
    if user_signed_in?
      @own_repos     = cached_repos 'repos', type: 'owner', per_page: '100'
      @starred_repos = cached_repos 'starred'
      @watched_repos = cached_repos 'subscriptions'
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
    @repo   = Repo.search_by(params[:repo][:name], params[:repo][:user_name]).first unless params_blank?
    @repo ||= Repo.new(repo_params)
    if @repo.save
      @repo_sub = current_user.repo_subscriptions.create(repo: @repo)
      flash[:notice] = "Added #{@repo.to_param} for triaging"
      SendSingleTriageEmailJob.perform_later(@repo_sub.id)
      redirect_to @repo
    else
      response = GitHubBub.get("/user/repos", type: "owner", token: current_user.token)
      @own_repos = response.json_body
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

  def remove
    @repos = []
    @repo = Repo.new(user_name: params[:user_name], name: name_from_params(params))

    Repo.all.each do |x|
      response = GitHubBub.get("/repos/#{Repo.first.user_name}/#{Repo.first.name}", { token: current_user.token })
      @parsed_response = JSON.parse(response.body)

      if @parsed_response["permissions"]["push"]
        @repos.push(x)
      end
    end
  end

  def destroy
    
    repo = Repo.find(params[:id])
    repo_subscriptions = RepoSubscription.where(repo_id: repo.id)

    repo_subscriptions.each do |x|
      user = User.find(x.user_id)
      UserMailer.inform_remove_repo(user, repo).deliver_now!
    end

    repo.destroy                                                                    

    redirect_to repos_remove_path
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
        params[:repo][:user_name] = $1.to_s
        params[:repo][:name] = $2.to_s
      end
    end

    def params_blank?
      repo_params.values.any?(&:blank?)
    end

    def cached_repos(type, options = {})
      Rails.cache.fetch("user/#{type}/#{current_user.id}", expires_in: 30.minutes) do
        repos_response = GitHubBub.get("/user/#{type}", { token: current_user.token }.merge(options))
        SortedRepoCollection.new(repos_response.json_body)
      end
    end
end
