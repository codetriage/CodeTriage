class Repo < ActiveRecord::Base

  validate :github_url_exists, :on => :create
  after_create :populate_issues!

  validates :name, :user_name, :presence => true

  has_many :issues
  has_many :repo_subscriptions
  has_many :users, :through => :repo_subscriptions

  def self.order_by_issue_count
    repos_group_query  = Repo.column_names.map  {|x| "repos.#{x}"}.join(',')
    issues_group_query = Issue.column_names.map {|x| "issues.#{x}"}.join(',')
    self.joins(:issues).group('issues.id', issues_group_query, repos_group_query).order('COUNT(issues) DESC').includes(:issues)
  end

  def github_url_exists
    response = GitHubBub::Request.fetch(api_issues_path, :page => 1, :sort => 'comments', :direction => 'desc')
    if response.code != 200
      errors.add(:expiration_date, "cannot reach api.github.com/#{api_issues_path} perhaps github is down, or you mistyped something?")
    end
  end

  def github_url
    File.join("http://github.com", username_repo)
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
      repo.populate_multi_issues!(:state => 'open')
    end
  end


  # This class is used by resque,
  # by default anything you put into the perform method
  # will be called for each object in the redis queue
  class PopulateIssues
    @queue = :populate_issues

    def self.perform(repo_id)
      repo = Repo.find(repo_id.to_i)
      repo.populate_all_open_isues
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
      options[:page ] += 1
      response = populate_issue(options)
    end
  end

end
