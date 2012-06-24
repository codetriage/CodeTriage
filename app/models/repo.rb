class Repo < ActiveRecord::Base

  validate :github_url_exists, :on => :create
  after_create :run_populate_issues

  validates :name, :user_name, :presence => true

  has_many :issues
  has_many :repo_subscriptions
  has_many :users, :through => :repo_subscriptions

  def github_url_exists
    response = GitHubBub::Request.fetch(api_issues_path, :page => 1, :sort => 'comments', :direction => 'desc')
    if response.code != 200
      errors.add(:expiration_date, "cannot reach api.github.com/#{api_issues_path} perhaps github is down, or you mistyped something?")
    end
  end

  def github_url
    File.join("http://github.com", username_repo)
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

  def to_params
  end

  def run_populate_issues
    Resque.enqueue(PopulateIssues, self.id)
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

    def populate_issue(page = 1)
    response = GitHubBub::Request.fetch(api_issues_path, :page => page, :sort => 'comments', :direction => 'desc')
    issues   = response.json_body
    issues.each do |issue|
      puts "Issue: number: #{issue['number']}, updated_at: #{issue['updated_at']}"
      issue_record = Issue.where(:number => issue['number']).first || Issue.create(:number => issue['number'], :repo => self)
      issue_record.update_attributes(:title      => issue['title'],
                                     :url        => issue['url'],
                                     :updated_at => issue['updated_at'])
    end
    response
  end


    def populate_all_open_isues
    page = 1
    response = populate_issue
    until response.last_page?
      page += 1
      response = populate_issue(page)
    end
  end

end
