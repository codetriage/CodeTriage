# frozen_string_literal: true

class PopulateDocsJob < RepoBasedJob
  around_perform do |_job, block|
    ActiveRecord::Base.uncached do
      block.call
    end
  end

  def perform(repo)
    repo.populate_docs!
  end
end
