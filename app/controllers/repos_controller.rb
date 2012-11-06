class ReposController < ApplicationController

  def index
    # TODO join and order by subscribers
    @repos = Repo.page(params[:page]).per_page(params[:per_page]||50)
  end

	def new
		@repo = Repo.new
	end

  def show
    @repo     = Repo.where(:id => params[:id]).includes(:issues).first
    @repo_sub = current_user.repo_subscriptions.where(:repo_id => @repo.id).includes(:issues).first if current_user

    @issues   = @repo.issues.page(params[:page]).per_page(params[:per_page]||20)
  end

	def create
    @repo =   Repo.where(name: params[:repo][:name].downcase, user_name: params[:repo][:user_name].downcase).first
    @repo ||= Repo.create(params[:repo])

    if @repo.save
      redirect_to @repo
    else
      render :new
    end
	end

end