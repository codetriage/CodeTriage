# frozen_string_literal: true

class PopulateIssuesJob < RepoBasedJob
  def perform(repo)
    @repo = repo
    @time_now = Time.now.utc
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

  def pr_attached_with_issue?(pull_request_hash)
    # issue_hash['pull_request'] has following structure
    #    pull_request: {
    #                    html_url: null,
    #                    diff_url: null,
    #                    patch_url: null
    #                  }
    # When all the values are nil, PR is not attached with the issue
    return false if pull_request_hash.blank?
    pull_request_hash.values.uniq != [nil]
  end

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

      upsert_mega_array = []
      fetcher.as_json.each do |github_issue_hash|
        last_touched_at = github_issue_hash['updated_at'] ? DateTime.parse(github_issue_hash['updated_at']) : nil
        pr_attached = pr_attached_with_issue?(github_issue_hash['pull_request'])

        upsert_mega_array << {
          repo_id: @repo.id,
          title: github_issue_hash['title'],
          url: github_issue_hash['url'],
          state: github_issue_hash['state'],
          html_url: github_issue_hash['html_url'],
          number: github_issue_hash['number'],
          pr_attached: pr_attached,
          last_touched_at: last_touched_at,
          updated_at: @time_now,
          created_at: @time_now
        }
      end

      Issue.upsert_all(upsert_mega_array, unique_by: [:number, :repo_id])

      !fetcher.last_page?
    end
  end
end
