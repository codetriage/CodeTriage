# frozen_string_literal: true

class Issue < ActiveRecord::Base
  OPEN   = "open"
  CLOSED = "closed"

  validates :state, inclusion: { in: [OPEN, CLOSED] }
  belongs_to :repo

  def valid_for_user?(user, can_access_network: !Rails.env.test?, repo: nil)
    if can_access_network
      update_issue!(repo)
      return false if commenting_users(repo).include?(user.github)
    end
    return false  if closed?
    return false  if pr_attached? && user.skip_issues_with_pr?
    true
  end

  def fetcher(repo = nil)
    @fetcher ||= GithubFetcher::Issue.new(
      owner_name: repo.try(:user_name) || owner_name,
      repo_name: repo.try(:name) || repo_name,
      number: number,
    )
  end

  def comments_fetcher(repo = nil)
    @comments_fetcher ||= GithubFetcher::IssueComments.new(
      owner_name: repo.try(:user_name) || owner_name,
      repo_name: repo.try(:name) || repo_name,
      number: number,
    )
  end

  def update_issue!(repo = nil)
    fetch = fetcher(repo)
    fetch.call(retry_on_bad_token: 3)
    update_from_github_hash!(fetch.as_json)
  end

  def self.closed
    where(state: CLOSED)
  end

  def self.open_issues
    where(state: OPEN)
  end

  def closed?
    state == CLOSED
  end

  def open?
    state == OPEN
  end

  def repo_name
    self.repo.name
  end

  def owner_name
    self.repo.user_name
  end

  def public_url
    "https://github.com/repos/#{repo.user_name}/#{repo.name}/issues/#{number}"
  end

  def commenting_users(repo = nil)
    fetch = comments_fetcher(repo)
    fetch.call(retry_on_bad_token: 3)
    fetch.commenters.sort
  end

  def self.find_or_create_from_hash!(issue_hash, repo)
    issue = Issue.find_or_create_by(number: issue_hash['number'], repo: repo)
    issue.update_from_github_hash!(issue_hash)
  end

  def update_from_github_hash!(issue_hash)
    last_touched_at = issue_hash['updated_at'] ? DateTime.parse(issue_hash['updated_at']) : nil

    self.update!(title: issue_hash['title'],
                 url: issue_hash['url'],
                 last_touched_at: last_touched_at,
                 state: issue_hash['state'],
                 html_url: issue_hash['html_url'],
                 pr_attached: pr_attached_with_issue?(issue_hash['pull_request']))
  rescue => e
    raise e, "#{e.message} issue_hash: #{issue_hash.inspect}"
  end

  def self.create_from_github_hash!(issue_hash, repo:)
    last_touched_at = issue_hash['updated_at'] ? DateTime.parse(issue_hash['updated_at']) : nil

    Issue.create!(repo_id: repo.id,
                  title: issue_hash['title'],
                  url: issue_hash['url'],
                  last_touched_at: last_touched_at,
                  state: issue_hash['state'],
                  html_url: issue_hash['html_url'],
                  pr_attached: pr_attached_with_issue?(issue_hash['pull_request']))

  rescue => e
    raise e, "#{e.message} issue_hash: #{issue_hash.inspect}"
  end

  def self.queue_mark_old_as_closed!
    where("state = ? and updated_at < ?", OPEN, 24.hours.ago)
      .update_all(state: CLOSED)
  end

  private

  def self.pr_attached_with_issue?(pull_request_hash)
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

  def pr_attached_with_issue?(pull_request_hash)
    self.class.pr_attached_with_issue?(pull_request_hash)
  end
end
