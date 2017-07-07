class Issue < ActiveRecord::Base
  OPEN   = "open"
  CLOSED = "closed"

  validates :state, inclusion: { in: [OPEN, CLOSED] }
  belongs_to :repo, counter_cache: true

  def valid_for_user?(user, skip_update = Rails.env.test?)
    unless skip_update
      update_issue!
      return false if commenting_users.include?(user.github)
    end
    return false  if closed?
    return false  if pr_attached? && user.skip_issues_with_pr?
    true
  end

  def fetcher
    @fetcher ||= GithubFetcher::Issue.new(self)
  end

  def update_issue!
    update_from_github_hash!(fetcher.issue_json)
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

  def commenting_users
    fetcher.commenters.sort
  end

  def self.find_or_create_from_hash!(issue_hash, repo)
    issue = Issue.find_or_create_by(number: issue_hash['number'], repo: repo)
    issue.update_from_github_hash!(issue_hash)
  end

  def update_from_github_hash!(issue_hash)
    self.update_attributes(title:           issue_hash['title'],
                           url:             issue_hash['url'],
                           last_touched_at: DateTime.parse(issue_hash['updated_at']),
                           state:           issue_hash['state'],
                           html_url:        issue_hash['html_url'],
                           pr_attached:     pr_attached_with_issue?(issue_hash['pull_request']))
  end

  def self.queue_mark_old_as_closed!
    where("state = ? and updated_at < ?", OPEN, 24.hours.ago).find_each do |issue|
      begin
        issue.update_attributes(state: CLOSED)
      rescue => e
        logger.debug e.inspect
      end
    end
  end

  private

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

end
