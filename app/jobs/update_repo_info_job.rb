class UpdateRepoInfoJob < ApplicationJob
  def perform(repo)
    repo.update_from_github
  end
end
