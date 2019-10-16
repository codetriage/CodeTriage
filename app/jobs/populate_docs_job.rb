# frozen_string_literal: true

class PopulateDocsJob < ApplicationJob
  def perform(repo_or_id)
    if repo_or_id.is_a?(Integer)
      repo = Repo.find(repo_or_id)
    else
      repo = repo_or_id
    end
    repo.populate_docs!
  end
end
