class PopulateIssuesJob < ApplicationJob
  def perform(repo)
    @repo = repo
    @state = 'open'
    populate_multi_issues!
  end

  attr_reader :repo, :state

  def populate_multi_issues!
    page = 1
    while populate_issues(page)
      page += 1
    end
  end

  private

  def fetcher(page)
    repo.issues_fetcher(page: page, state: state)
  end

  attr_reader :repo, :state

  def populate_issues(page)
    fetcher = fetcher(page)
    json = fetcher.as_json

    if fetcher.error?
      repo.update_attributes(github_error_msg: fetcher.error_message)
      false
    else
      fetcher.as_json.each do |issue_hash|
        Rails.logger.info "Issue: number: #{issue_hash['number']}, "\
                    "updated_at: #{issue_hash['updated_at']}"
        Issue.find_or_create_from_hash!(issue_hash, repo)
      end
      fetcher.more_issues?
    end
  end
end
