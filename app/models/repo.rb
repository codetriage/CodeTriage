class Repo < ActiveRecord::Base
  include ResqueDef

  validate :github_url_exists, on: :create
  validates :name, uniqueness: {scope: :user_name, case_sensitive: false }

  after_create :populate_issues!, :update_repo_info!

  before_validation :downcase_name, :strip_whitespaces

  validates :name, :user_name, presence: true

  has_many :issues
  has_many :repo_subscriptions
  has_many :users, through: :repo_subscriptions

  has_many :subscribers, through: :repo_subscriptions, source: :user

  delegate :open_issues, to: :issues
  before_save :set_full_name

  def strip_whitespaces
    self.name.strip!
    self.user_name.strip!
  end

  def set_full_name
    self.full_name = "#{user_name}/#{name}"
  end

  def subscriber_count
    users.count
  end

  # pulls out number of issues divided by number of subscribers
  def self.order_by_need
     joins(:repo_subscriptions).order("issues_count::float/COUNT(repo_subscriptions.repo_id) DESC").group("repos.id")
  end

  # these repos have no subscribers and have no buisness being in our database
  def self.inactive
    joins("LEFT OUTER JOIN repo_subscriptions on repos.id = repo_subscriptions.repo_id").where("repo_subscriptions.repo_id is null")
  end

  def self.not_in(*ids)
    where("repos.id not in (?)", ids)
  end

  def self.rand
    order("random()")
  end

  def self.all_languages
    self.select("language").group("language").map(&:language).reject(&:blank?)
  end

  def self.repos_needing_help_for_user(user)
    if user && user.has_favorite_languages?
      where(language: user.favorite_languages)
    else
      self
    end.with_some_issues.order_by_issue_count
  end

  def force_issues_count_sync!
     self.update_attributes(issues_count: self.issues.where(state: "open").count)
  end

  def to_param
    path
  end

  def downcase_name
    self.name      = self.name.downcase
    self.user_name = self.user_name.downcase
  end

  def self.order_by_issue_count
    self.order("issues_count DESC")
  end

  def self.search_by(repo_name, user_name)
    where(name: repo_name.downcase.strip, user_name: user_name.downcase.strip)
  end

  def self.with_some_issues
    self.where("issues_count > 0")
  end

  def github_url_exists
    GitHubBub.get(api_issues_path, page: 1, sort: 'comments', direction: 'desc')
  rescue GitHubBub::RequestError
    errors.add(:expiration_date, "cannot reach api.github.com/#{api_issues_path} perhaps github is down, or you mistyped something?")
  end

  def github_url
    File.join('https://github.com', path)
  end

  def issues_url
    File.join(github_url, 'issues')
  end

  def path
    "#{user_name}/#{name}"
  end

  def api_issues_path
    File.join('repos', path, '/issues')
  end

  def api_issues_url
    File.join("https://api.github.com", api_issues_path)
  end

  def populate_issues!
    background_populate_issues(self.id)
  end

  def self.exists_with_name?(name)
    user_name, repo_name = name.downcase.split(?/)
    Repo.exists?(user_name: user_name, name: repo_name)
  end

  def self.order_by_subscribers
    joins("LEFT OUTER JOIN repo_subscriptions
           ON repo_subscriptions.repo_id = repos.id
           LEFT OUTER JOIN users ON users.id = repo_subscriptions.user_id").
      group("repos.id").
      order("count(users.id) DESC")
  end

  # This class is used by resque,
  # by default anything you put into the perform method
  # will be called for each object in the redis queue
  resque_def(:background_populate_issues) do |id|
    begin
      repo = Repo.find(id.to_i)
      repo.populate_multi_issues!(state: 'open')
    rescue GitHubBub::RequestError => e
      repo.update_attributes(github_error_msg: e.message)
    end
  end


  def populate_issue(options = {})
    page  = options[:page]||1
    state = options[:state]||"open"
    response = GitHubBub.get(api_issues_path, state:     state,
                                              page:      page,
                                              sort:      'comments',
                                              direction: 'desc')
    response.json_body.each do |issue_hash|
      logger.info "Issue: number: #{issue_hash['number']}, updated_at: #{issue_hash['updated_at']}"
      Issue.find_or_create_from_hash!(issue_hash, self)
    end
    response
  end


  def populate_multi_issues!(options = {})
    options[:state] ||= "open"
    options[:page]  ||= 1
    response = populate_issue(options)
    until response.last_page?
      options[:page] += 1
      response = populate_issue(options)
    end
  end

  def update_from_github
    resp = GitHubBub.get(repo_path).json_body
    self.language    = resp['language']
    self.description = resp['description']
    self.save
  end

  def repo_path
    File.join 'repos', path
  end

  def update_repo_info!
    background_update_repo_info(self.id)
  end

  resque_def(:background_update_repo_info) do |id|
    repo = Repo.find(id)
    repo.update_from_github
  end

  def self.find_by_full_name(full_name)
    Repo.includes(:issues).find_by!(full_name: full_name)
  end
end
