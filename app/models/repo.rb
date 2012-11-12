class Repo < ActiveRecord::Base

  validate :github_url_exists, :on => :create
  after_create :populate_issues!

  before_validation :downcase_name

  validates :name, :user_name, :presence => true
  validates :name, :uniqueness => {:scope => :user_name}

  has_many :issues
  has_many :repo_subscriptions
  has_many :users, :through => :repo_subscriptions


  # pulls out number of issues divided by number of subscribers
  def self.order_by_need
     joins(:repo_subscriptions).order("issues_count::float/COUNT(repo_subscriptions.repo_id) DESC").group("repos.id")
  end

  def self.not_in(*ids)
    where("repos.id not in (?)", ids)
  end

  def self.rand
    order("random()")
  end

  def force_issues_count_sync!
     self.update_attributes(issues_count: self.issues.where(state: "open").count)
  end

  def to_param
    "#{user_name}/#{name}"
  end

  def downcase_name
    self.name      = self.name.downcase
    self.user_name = self.user_name.downcase
  end

  def self.order_by_issue_count
    self.order("issues_count DESC")
  end

  def github_url_exists
    return true if Rails.env.test? ## TODO fixme with propper stubs, perhaps factories
    response = GitHubBub::Request.fetch(api_issues_path, :page => 1, :sort => 'comments', :direction => 'desc')
    if response.code != 200
      errors.add(:expiration_date, "cannot reach api.github.com/#{api_issues_path} perhaps github is down, or you mistyped something?")
    end
  end

  def github_url
    File.join("https://github.com", username_repo)
  end

  def issues_url
    File.join(github_url, 'issues')
  end

  def path
    username_repo
  end

  def api_issues_path
    File.join('repos', path, '/issues')
  end

  def api_issues_url
    File.join("https://api.github.com", api_issues_path)
  end

  def username_repo
    "#{user_name}/#{self.name}"
  end

  def populate_issues!
    Resque.enqueue(PopulateIssues, self.id)
  end

  def self.queue_populate_open_issues!
    find_each do |repo|
      repo.populate_issues!
    end
  end

  # This class is used by resque,
  # by default anything you put into the perform method
  # will be called for each object in the redis queue
  class PopulateIssues
    @queue = :populate_issues

    def self.perform(repo_id)
      repo = Repo.find(repo_id.to_i)
      repo.populate_multi_issues!(:state => 'open')
    end
  end

  def populate_issue(options = {})
    page  = options[:page]||1
    state = options[:state]||"open"
    response = GitHubBub::Request.fetch(api_issues_path, :state     => state,
                                                         :page      => page,
                                                         :sort      => 'comments',
                                                         :direction => 'desc')
    response.json_body.each do |issue_hash|
      puts "Issue: number: #{issue_hash['number']}, updated_at: #{issue_hash['updated_at']}"
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

end
