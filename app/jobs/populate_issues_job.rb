class PopulateIssuesJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    begin
      repo = Repo.find(id.to_i)
      repo.populate_multi_issues!(state: 'open')
    rescue GitHubBub::RequestError => e
      repo.update_attributes(github_error_msg: e.message)
    end
  end
end
