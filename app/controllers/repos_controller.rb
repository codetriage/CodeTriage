class ReposController < ApplicationController

  def index
    # TODO join and order by subscribers
    @repos = Repo.page(params[:page]).per_page(params[:per_page]||50)
  end

	def new
		@repo = Repo.new
	end

  def show
    @repo   = Repo.where(:id => params[:id]).includes(:issues).first
    @issues = @repo.issues.page(params[:page]).per_page(params[:per_page]||20)
  end

	def create
    @repo = Repo.create(params[:repo])

    if @repo.save
      redirect_to @repo
    else
      render :new
    end
	end

end