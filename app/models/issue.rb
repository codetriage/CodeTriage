class Issue < ActiveRecord::Base
  include ResqueDef

  OPEN   = "open"
  CLOSED = "closed"

  validates :state, :inclusion => { :in => [OPEN, CLOSED] }

  belongs_to :repo

  after_save    :update_counter_cache
  after_destroy :update_counter_cache
  attr_protected :admin


  def valid_for_user?(user)
    update_issue!
    return false if closed?
    return false if commenting_users.include? user.github
    true
  end

  def update_counter_cache
    return true unless self.state_changed? # only continue if state has changed
    return true if repo.blank?
    self.repo.force_issues_count_sync!
    true
  end

  def update_issue!
    response = GitHubBub.get(api_path).json_body
    self.update_from_github_hash!(response)
  end

  def self.closed
    where(state: CLOSED)
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
    issue =   Issue.where( number:  issue_hash['number'], repo_id: repo.id).first
    issue ||= Issue.create(number:  issue_hash['number'], repo:    repo)
    issue.update_from_github_hash!(issue_hash)
  end

  def update_from_github_hash!(issue_hash)
    self.update_attributes(title:           issue_hash['title'],
                           url:             issue_hash['url'],
                           last_touched_at: DateTime.parse(issue_hash['updated_at']),
                           state:           issue_hash['state'],
                           html_url:        issue_hash['html_url'])
  end


  def self.queue_mark_old_as_closed!
    find_each(:conditions => ["state = ? and updated_at < ?", OPEN, 24.hours.ago]) do |issue|
      self.delay_mark_closed(issue.id)
    end
  end

  resque_def(:delay_mark_closed) do |id|
    issue = Issue.find(id)
    issue.update_attributes(state: CLOSED)
  end
end
