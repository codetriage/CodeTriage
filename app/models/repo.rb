require 'docs_doctor/parsers/ruby/yard'

class Repo < ActiveRecord::Base
  validate :github_url_exists, on: :create
  validates :name, uniqueness: {scope: :user_name, case_sensitive: false }
  validates :name, :user_name, presence: true

  has_many :issues
  has_many :repo_subscriptions
  has_many :users, through: :repo_subscriptions
  has_many :subscribers, through: :repo_subscriptions, source: :user
  has_many :doc_classes, dependent: :destroy
  has_many :doc_methods, dependent: :destroy
  delegate :open_issues, to: :issues

  before_validation :downcase_name, :strip_whitespaces
  before_save :set_full_name
  after_create :background_populate_issues!, :update_repo_info!, :background_populate_docs!

  CLASS_FOR_DOC_LANGUAGE = { "Ruby" => DocsDoctor::Parsers::Ruby::Yard }

  def can_doctor_docs?
    CLASS_FOR_DOC_LANGUAGE[self.language]
  end

  def populate_docs!
    return unless can_doctor_docs?

    fetcher = GithubFetcher.new(full_name)
    self.update!(commit_sha: fetcher.commit_sha)
    parser  = Repo::CLASS_FOR_DOC_LANGUAGE[self.language].new(fetcher.clone)
    parser.process
    parser.store(self)
  end

  def background_populate_issues!
    PopulateIssuesJob.perform_later(self)
  end

  def background_populate_docs!
    PopulateDocsJob.perform_later(self)
  end

  def methods_missing_docs
    doc_methods.where(doc_methods: {doc_comments_count: 0})
  end

  def methods_with_docs
    doc_methods.where("doc_comments_count > 0")
  end

  def classes_missing_docs
    doc_classes.where(doc_classes: {doc_comments_count: 0})
  end


  def color
    case weight
    when "low"
      "5bb878".freeze
    when "medium"
      "eba117".freeze
    when "high"
      "e25443".freeze
    else
      "lightgrey".freeze
    end
  end

  def weight
    case issues_count
    when 0..199
      "low".freeze
    when 200..799
      "medium".freeze
    when 800..Float::INFINITY
      "high".freeze
    else
      "".freeze
    end
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
    self.select("language").group("language").order("language ASC").map(&:language).reject(&:blank?)
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

  def path
    "#{user_name}/#{name}"
  end

  def api_issues_path
    File.join('repos', path, '/issues')
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
    self.stars_count = resp['stargazers_count']
    self.save
  end

  def repo_path
    File.join 'repos', path
  end

  def self.find_by_full_name(full_name)
    Repo.find_by!(full_name: full_name)
  end

  private

  def update_repo_info!
    UpdateRepoInfoJob.perform_later(self)
  end

  def downcase_name
    self.name.downcase!
    self.user_name.downcase!
  end

  def set_full_name
    self.full_name = "#{user_name}/#{name}"
  end

  def strip_whitespaces
    self.name.strip!
    self.user_name.strip!
  end

end
