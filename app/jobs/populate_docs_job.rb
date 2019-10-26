# frozen_string_literal: true

class PopulateDocsJob < RepoBasedJob
  def perform(repo)
    repo.populate_docs!
  end
end
