# frozen_string_literal: true

class PopulateIssuesJob < ApplicationJob
  def perform(repo_or_id)
    if repo_or_id.is_a?(Integer)
      repo = Repo.find(repo_or_id)
    else
      repo = repo_or_id
    end

    @repo = repo
    populate_multi_issues!
  end

  def populate_multi_issues!
    page_number = 1
    while populate_issues(page_number)
      page_number += 1
    end
    @repo.force_issues_count_sync!
  end

  private

  attr_reader :repo

  def populate_issues(page_number)
    fetcher = repo.issues_fetcher
    fetcher.page = page_number

    fetcher.call(retry_on_bad_token: 3)

    if fetcher.error?
      repo.update(github_error_msg: fetcher.error_message)
      false
    else
      unless fetcher.as_json.is_a?(Array)
        raise "Error grabbing issues status: #{fetcher.status}, repo_id: #{repo.id}.\nExpected result to be an array of hashes but is #{fetcher.as_json}"
      end

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
        issue_hash = issue_number_to_github_hash.fetch(issue.number)
        issue.update_from_github_hash!(issue_hash)
      end

      # TODO fix, some issues have duplicate numbers in tests
      # We should ideally delete in the first loop
      # but cannot for now due to tests
      issues.each do |issue|
        issue_number_to_github_hash.delete(issue.number)
      end

      # Create issues that didn't
      issue_number_to_github_hash.each_value do |issue_hash|
        Issue.create_from_github_hash!(issue_hash, repo: @repo)
      end

      !fetcher.last_page?
    end
  end
end
