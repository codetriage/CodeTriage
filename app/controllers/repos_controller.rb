class ReposController < ApplicationController

  before_filter :fix_name, :only => :show

  def index
    # TODO join and order by subscribers
    @repos = Repo.order(:name).page(params[:page]).per_page(params[:per_page]||50)
  end

  def new
    @repo = Repo.new(user_name: params[:user_name], name: params[:name])
    own_repos_response = GitHubBub::Request.fetch("/user/repos", {type: "owner"}, current_user)
    @own_repos = SortedRepoCollection.new(own_repos_response.json_body)

    starred_repos_response = GitHubBub::Request.fetch("/user/starred", nil, current_user)
    @starred_repos = SortedRepoCollection.new(starred_repos_response.json_body)

    watched_repos_response = GitHubBub::Request.fetch("/user/subscriptions", nil, current_user)
    @watched_repos = SortedRepoCollection.new(watched_repos_response.json_body)
  end

  def show
    @repo     = Repo.where(user_name: params[:user_name], name: params[:name])
    if @repo.blank?
      redirect_to new_repo_path(user_name: params[:user_name], name: params[:name]), :notice => "Could not find repo: \"#{params[:user_name]}/#{params[:name]}\" on Code Triage, add it?"
    else
      @repo     = @repo.includes(:issues).first
      @issues   = @repo.issues.where(state: 'open').page(params[:page]).per_page(params[:per_page]||20)
      @repo_sub = current_user.repo_subscriptions.where(:repo_id => @repo.id).includes(:issues).first if current_user
    end
  end

  def create
    @repo =   Repo.where(name: params[:repo][:name].downcase, user_name: params[:repo][:user_name].downcase).first
    @repo ||= Repo.create(params[:repo])

    if @repo.save
      flash[:notice] = "Added #{@repo.to_param} for triaging"
      repo_sub = RepoSubscription.create(:repo => @repo, :user => current_user)
      repo_sub.send_triage_email!

      redirect_to @repo
    else
      response = GitHubBub::Request.fetch("/user/repos", {type: "owner"}, current_user)
      @own_repos = response.json_body
      render :new
    end
  end

  def fix_name
    params[:name] = [params[:name], params[:format]].compact.join('.')
    true
  end

end
