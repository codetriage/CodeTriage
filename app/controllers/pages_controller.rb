class PagesController < ApplicationController
  def index
    @repos = Repo.joins(:issues).group('issues.id', 'repos.id').order('COUNT(issues)').includes(:issues).first(50)
  end
end
