# frozen_string_literal: true

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
    @repo.force_issues_count_sync!
  end

  private

  attr_reader :repo

  def populate_issues(page)
    fetcher = repo.issues_fetcher
    fetcher.page = page

    if fetcher.error?
      repo.update(github_error_msg: fetcher.error_message)
      false
    else
      issue_number_to_github_hash = {}
      fetcher.as_json.each do |github_issue_hash|
        issue_number = github_issue_hash['number']
        issue_number_to_github_hash[issue_number] = github_issue_hash
      end

      # Update issues that do exist
      issues = Issue
               .where("number in (?)", issue_number_to_github_hash.keys)
               .where(repo_id: repo.id)
      issues.each do |issue|
        issue_hash = issue_number_to_github_hash.delete(issue.id)
        issue.update_from_github_hash!(issue_hash)
      end

      # Create issues that didn't
      issue_number_to_github_hash.each_value do |issue_hash|
        Issue.create_from_github_hash!(issue_hash)
      end

      !fetcher.last_page?
    end
  end
end
