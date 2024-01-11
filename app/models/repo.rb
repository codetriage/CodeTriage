# frozen_string_literal: true

require "docs_doctor/parsers/ruby/yard"

class Repo < ActiveRecord::Base
  # Now done at the DB level # validates :name, uniqueness: {scope: :user_name, case_sensitive: false }
  attr_accessor :skip_validation
  validate :github_url_exists, on: :create, unless: :skip_validation
  validates :name, :user_name, presence: true

  has_many :issues, dependent: :destroy
  has_many :repo_subscriptions, dependent: :restrict_with_error
  has_many :users, through: :repo_subscriptions
  has_many :subscribers, through: :repo_subscriptions, source: :user
  has_many :doc_classes, dependent: :destroy
  has_many :doc_methods, dependent: :destroy
  delegate :open_issues, to: :issues

  has_many :repo_labels
  has_many :labels, through: :repo_labels

  before_validation :set_full_name!, :downcase_name, :strip_whitespaces
  after_create :background_populate_issues!, :update_repo_info!, :background_populate_docs!

  CLASS_FOR_DOC_LANGUAGE = {"ruby" => DocsDoctor::Parsers::Ruby::Yard}

  scope :archived, -> { where(archived: true) }
  scope :not_archived, -> { where(archived: false) }
  scope :removed_from_github, -> { where(removed_from_github: true) }
  scope :not_removed_from_github, -> { where(removed_from_github: false) }

  scope :active, -> { not_archived.not_removed_from_github }

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
    @fetcher_json ||= fetcher.as_json
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

  def populate_docs!(commit_sha: commit_sha_fetcher.commit_sha, location: nil, has_subscribers: !docs_subscriber_count.zero?)
    return "Skipped, lang not supported" unless can_doctor_docs?
    return "Skipped, no commit SHA" unless commit_sha
    return "Skipped, no subscribers" unless has_subscribers

    update!(commit_sha: commit_sha)
    location ||= fetcher.clone

    parser = class_for_doc_language.new(location)
    parser.process
    parser.store(self)
    :success
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
      "5bb878"
    when "medium"
      "eba117"
    when "high"
      "e25443"
    else
      "lightgrey"
    end
  end

  def weight
    case issues_count
    when 0..199
      "low"
    when 200..799
      "medium"
    when 800..Float::INFINITY
      "high"
    else
      ""
    end
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
    update!(
      issues_count: issues.where(state: "open").count,
      docs_subscriber_count: query_docs_subscriber_count
    )
  end

  def to_param
    full_name
  end

  def self.order_by_issue_count
    order("issues_count DESC")
  end

  def self.search_by(repo_name, user_name)
    where(name: repo_name.downcase.strip, user_name: user_name.downcase.strip)
  end

  def self.with_some_issues
    where("issues_count > 0")
  end

  def self.without_user_subscriptions(user_id)
    user_subscribed_repo_ids = RepoSubscription.where(user_id: user_id).select(:repo_id)
    where.not(id: user_subscribed_repo_ids)
  end

  def github_url
    File.join("https://github.com", full_name)
  end

  def self.exists_with_name?(name)
    user_name, repo_name = name.downcase.split("/")
    Repo.exists?(user_name: user_name, name: repo_name)
  end

  def update_from_github
    if fetcher.not_found?
      update!(removed_from_github: true)
    elsif fetcher.success?
      repo_full_name = fetcher_json.fetch("full_name", full_name)

      if repo_full_name != full_name && self.class.exists_with_name?(repo_full_name)
        ActiveRecord::Base.transaction do
          new_repo = self.class.find_by(full_name: repo_full_name)

          repo_subscriptions.each do |existing_subscription|
            new_repo.repo_subscriptions.find_or_create_by!(user_id: existing_subscription.user_id) do |new_subscription|
              new_subscription.last_sent_at = existing_subscription.last_sent_at
              new_subscription.email_limit = existing_subscription.email_limit
              new_subscription.write = existing_subscription.write
              new_subscription.read = existing_subscription.read
              new_subscription.write_limit = existing_subscription.write_limit
              new_subscription.read_limit = existing_subscription.read_limit
            end
          end

          repo_subscriptions.destroy_all
          destroy!
        end

        return
      end

      repo_user_name, repo_name = repo_full_name.split("/")
      update!(
        name: repo_name,
        user_name: repo_user_name,
        language: fetcher_json.fetch("language", language),
        description: fetcher_json.fetch("description", description)&.first(255),
        full_name: repo_full_name,
        removed_from_github: false,
        archived: fetcher_json.fetch("archived", archived)
      )
    end
  end

  def repo_path
    File.join "repos", path
  end

  def active?
    removed_from_github == false && archived == false
  end

  def self.find_by_full_name(full_name)
    Repo.find_by!(full_name: full_name)
  end

  def update_repo_info!
    UpdateRepoInfoJob.perform_later(self)
  end

  private def downcase_name
    name.downcase!
    user_name.downcase!
  end

  private def set_full_name!
    if full_name && user_name.blank?
      self.user_name, self.name = full_name.split("/")
    else
      self.full_name = "#{user_name}/#{name}"
    end
  end

  private def strip_whitespaces
    name.strip!
    user_name.strip!
  end

  private def github_url_exists
    if issues_fetcher.error?
      errors.add(
        :expiration_date,
        "cannot reach api.github.com/#{issues_fetcher.send(:api_path)} perhaps github is down, or you mistyped something?"
      )
    end
  end

  private def query_docs_subscriber_count
    sql = <<~SQL
      SELECT count(*)
      FROM repo_subscriptions
      WHERE
        repo_id = :repo_id AND
        (read = true OR write = true)
    SQL
    RepoSubscription.count_by_sql([sql, {repo_id: id}])
  end
end
