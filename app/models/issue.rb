class Issue < ActiveRecord::Base
  OPEN   = "open"
  CLOSED = "closed"

  validates :state, inclusion: { in: [OPEN, CLOSED] }
  belongs_to :repo
  has_many :labels, class_name: :IssueLabel, dependent: :delete_all

  after_save    :update_repo_issues_count
  after_update  :update_repo_issues_count
  after_destroy :update_repo_issues_count_on_destroy


  def update_repo_issues_count_on_destroy
    repo.issues_count = repo.issues.where(state: OPEN).count
    repo.save
    true
  end

  def update_repo_issues_count
    return true unless self.state_changed? # only continue if state has changed
    return true if repo.blank?
    repo.issues_count = repo.issues.where(state: OPEN).count
    repo.save
    true
  end

  def valid_for_user?(user, skip_update = Rails.env.test?)
    unless skip_update
      update_issue!
      return false if commenting_users.include?(user.github)
    end
    return false  if closed?
    return false  if pr_attached? && user.skip_issues_with_pr?
    true
  end

  def update_issue!
    response = GitHubBub.get(api_path).json_body
    self.update_from_github_hash!(response)
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

  def api_path
    "/repos/#{owner_name}/#{repo_name}/issues/#{number}"
  end

  def public_url
    "https://github.com/repos/#{repo.user_name}/#{repo.name}/issues/#{number}"
  end

  def commenting_users
    response = GitHubBub.get(File.join(api_path, "/comments")).json_body
    response.collect{|comment| comment["user"]["login"]}.uniq.sort
  end

  def self.find_or_create_from_hash!(issue_hash, repo)
    issue = Issue.find_or_create_by(number: issue_hash['number'], repo: repo)
    issue.update_from_github_hash!(issue_hash)
  end

  def update_from_github_hash!(issue_hash)
    labels = issue_hash['labels'].map{|l| label_from_github_hash l}
    self.update_attributes(title:           issue_hash['title'],
                           url:             issue_hash['url'],
                           last_touched_at: DateTime.parse(issue_hash['updated_at']),
                           state:           issue_hash['state'],
                           labels:          labels,
                           label_count:     labels.length,
                           html_url:        issue_hash['html_url'],
                           pr_attached:     pr_attached_with_issue?(issue_hash['pull_request']))
  end

  def label_from_github_hash(label_hash)
    IssueLabel.new(
      repo_id: repo_id,
      issue_id: id,
      name: label_hash.fetch('name'))
  end

  def self.queue_mark_old_as_closed!
    where("state = ? and updated_at < ?", OPEN, 24.hours.ago).find_each do |issue|
      begin
        issue.update_attributes(state: CLOSED)
      rescue => e
        puts e.inspect
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
