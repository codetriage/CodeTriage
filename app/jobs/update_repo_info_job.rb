class UpdateRepoInfoJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    repo = Repo.find(id)
    repo.update_from_github
  end
end
