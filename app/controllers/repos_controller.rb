require File.expand_path("../../../lib/sorted_repo_collection", __FILE__)

class ReposController < RepoBasedController

  def index
    # TODO join and order by subscribers
    @repos = Repo.order(:name).page(params[:page]).per_page(params[:per_page]||50)
  end

  def new
    @repo = Repo.new(user_name: params[:user_name], name: name_from_params(params))

    if user_signed_in?
      own_repos_response = GitHubBub.get("/user/repos", token: current_user.token, type: "owner", per_page: '100')
      @own_repos = SortedRepoCollection.new(own_repos_response.json_body)

      starred_repos_response = GitHubBub.get("/user/starred", token: current_user.token)
      @starred_repos = SortedRepoCollection.new(starred_repos_response.json_body)

      watched_repos_response = GitHubBub.get("/user/subscriptions", token: current_user.token)
      @watched_repos = SortedRepoCollection.new(watched_repos_response.json_body)
    end
  end

  def show
    @repo     = find_repo(params)
    @issues   = @repo.issues.where(state: 'open').page(params[:page]).per_page(params[:per_page]||20)
    @repo_sub = current_user.repo_subscriptions.where(:repo_id => @repo.id).includes(:issues).first if current_user
    @subscribers = @repo.subscribers.public.limit(27)
  end

  def create
    @repo =   Repo.where(name: params[:repo][:name].downcase.strip, user_name: params[:repo][:user_name].downcase.strip).first
    @repo ||= Repo.create(params[:repo])
 
    if @repo.save
      flash[:notice] = "Added #{@repo.to_param} for triaging"
      repo_sub = RepoSubscription.create(:repo => @repo, :user => current_user)
      repo_sub.send_triage_email!

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
    if @repo.update_attributes(params[:repo])
      redirect_to @repo, :notice => "Repo updated"
    else
      render :edit
    end
  end

end
