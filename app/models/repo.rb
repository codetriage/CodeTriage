# frozen_string_literal: true

require 'docs_doctor/parsers/ruby/yard'

class Repo < ActiveRecord::Base
  # Now done at the DB level # validates :name, uniqueness: {scope: :user_name, case_sensitive: false }
  validates :name, :user_name, presence: true
  validate :github_url_exists, on: :create

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

  CLASS_FOR_DOC_LANGUAGE = { "ruby" => DocsDoctor::Parsers::Ruby::Yard }

  def class_for_doc_language
    language && CLASS_FOR_DOC_LANGUAGE[language.downcase]
  end

  def can_doctor_docs?
    class_for_doc_language.present?
  end

  def fetcher
    @fetcher ||= GithubFetcher::Repo.new(user_name: user_name, name: name)
  end

  def fetcher_json
    fetcher.as_json
  end

  def issues_fetcher
    @issues_fetcher ||= GithubFetcher::Issues.new(
      user_name: user_name,
      name: name
    )
  end

  def commit_sha_fetcher
    @commit_sha_fetcher ||= GithubFetcher::CommitSha.new(
      user_name: user_name,
      name: name,
      default_branch: fetcher.default_branch
    )
  end

  def populate_docs!(commit_sha: commit_sha_fetcher.commit_sha, location: nil)
    return unless can_doctor_docs?
    return unless commit_sha

    self.update!(commit_sha: commit_sha)
    location ||= fetcher.clone

    parser = class_for_doc_language.new(location)
    parser.in_fork do
      parser.process
      parser.store(self)
    end
  end

  def background_populate_issues!
    PopulateIssuesJob.perform_later(self)
  end

  def background_populate_docs!
    PopulateDocsJob.perform_later(self)
  end

  def methods_missing_docs
    doc_methods.where(doc_methods: { doc_comments_count: 0 })
  end

  def methods_with_docs
    doc_methods.where("doc_comments_count > 0")
  end

  def classes_missing_docs
    doc_classes.where(doc_classes: { doc_comments_count: 0 })
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
    joins(:repo_subscriptions)
      .order(Arel.sql("issues_count::float/COUNT(repo_subscriptions.repo_id) DESC"))
      .group("repos.id")
  end

  # these repos have no subscribers and have no business being in our database
  def self.inactive
    joins("LEFT OUTER JOIN repo_subscriptions on repos.id = repo_subscriptions.repo_id").where("repo_subscriptions.repo_id is null")
  end

  def self.not_in(*ids)
    where("repos.id not in (?)", ids)
  end

  @@max_id = nil
  def self.rand
    @@max_id = self.maximum(:id) if @@max_id.nil?

    where("id >= ?", Random.new.rand(1..@@max_id))
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
    self.update!(issues_count: self.issues.where(state: "open").count)
  end

  def to_param
    full_name
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

  def self.without_user_subscriptions(user_id)
    user_subscribed_repo_ids = RepoSubscription.where(user_id: user_id).select(:repo_id)
    self.where.not(id: user_subscribed_repo_ids)
  end

  def github_url
    File.join('https://github.com', full_name)
  end

  def self.exists_with_name?(name)
    user_name, repo_name = name.downcase.split(?/)
    Repo.exists?(user_name: user_name, name: repo_name)
  end

  def update_from_github
    json = fetcher.as_json
    self.update(
      language: json.fetch('language', language),
      description: json.fetch('description', description)&.first(255),
      stars_count: json.fetch('stargazers_count', stars_count)
    )
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

  def github_url_exists
    if issues_fetcher.error?
      errors.add(
        :expiration_date,
        "cannot reach api.github.com/#{issues_fetcher.send(:api_path)} perhaps github is down, or you mistyped something?"
      )
    end
  end
end
