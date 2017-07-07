class PopulateIssuesJob < ApplicationJob
  def perform(repo)
    PopulateIssues.(repo)
  end
end
