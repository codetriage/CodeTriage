class ReposController < ApplicationController

  def index
    @repos = Repo.page(params[:page]).per_page(params[:per_page]||50)
  end

	def new
		@repo = Repo.new
	end

  def show
    @repo = Repo.find(params[:id])
  end

	def create
	end

end