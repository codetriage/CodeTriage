# frozen_string_literal: true

class PopulateDocsJob < ApplicationJob
  def perform(repo)
    repo.populate_docs!
  end
end
