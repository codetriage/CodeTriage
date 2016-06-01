class PopulateDocsJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    repo = Repo.find(id.to_i)
    repo.populate_docs!
  end
end
