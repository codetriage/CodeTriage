class PopulateIssuesJob < ApplicationJob
  def perform(repo)
    @repo = repo
    populate_multi_issues!
  end

  def populate_multi_issues!
    page = 1
    while populate_issues(page)
      page += 1
    end
  end

  private

  attr_reader :repo

  def populate_issues(page)
    fetcher = repo.issues_fetcher
    fetcher.page = page

    if fetcher.error?
      repo.update_attributes(github_error_msg: fetcher.error_message)
      false
    else
      fetcher.as_json.each do |issue_hash|
        Rails.logger.info "Issue: number: #{issue_hash['number']}, "\
                    "updated_at: #{issue_hash['updated_at']}"
        Issue.find_or_create_from_hash!(issue_hash, repo)
      end
      !fetcher.last_page?
    end
  end
end
