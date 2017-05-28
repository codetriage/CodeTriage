class PopulateIssuesJob < ApplicationJob
  def perform(repo)
    begin
      repo.populate_multi_issues!(state: 'open')
    rescue GitHubBub::RequestError => e
      repo.update_attributes(github_error_msg: e.message)
    end
  end
end
