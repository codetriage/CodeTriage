class PagesController < ApplicationController
  def index
    @repos = Repo.order_by_issue_count
  end

  def show
    render "pages/show/#{params[:id]}"
  end
end
