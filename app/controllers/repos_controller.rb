class ReposController < ApplicationController

  def index
    # TODO join and order by subscribers
    @repos = Repo.page(params[:page]).per_page(params[:per_page]||50)
  end

	def new
		@repo = Repo.new
	end

  def show
    @repo     = Repo.where(:id => params[:id]) if params[:id]
    @repo     ||= Repo.where(user_name: params[:user_name], name: [params[:name], params[:format]].compact.join('.'))
    @repo     = @repo.includes(:issues).first
    @issues   = @repo.issues.where(state: 'open').page(params[:page]).per_page(params[:per_page]||20)
    @repo_sub = current_user.repo_subscriptions.where(:repo_id => @repo.id).includes(:issues).first if current_user
  end

	def create
    @repo =   Repo.where(name: params[:repo][:name].downcase, user_name: params[:repo][:user_name].downcase).first
    @repo ||= Repo.create(params[:repo])

    if @repo.save
      repo_sub = RepoSubscription.create(:repo => @repo, :user => current_user)
      repo_sub.send_triage_email!

      redirect_to @repo
    else
      render :new
    end
	end

end