# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules (but not :registerable). Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable,
  # :omniauthable, and :registerable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :omniauthable

  validates_uniqueness_of :email,    allow_blank: true, if: :email_changed?
  validates_length_of     :password, within: 8..128, allow_blank: true
  validates :github, presence: true, uniqueness: true
  validates :email_frequency, inclusion: { in: EmailRateLimit::USER_STATES.map(&:to_s) + [nil], message: "Not a valid frequency, pick from #{EmailRateLimit::USER_STATES}" }

  # Setup accessible (or protected) attributes for your model

  has_many :repo_subscriptions, dependent: :destroy
  has_many :repos, through: :repo_subscriptions

  has_many :issue_assignments, through: :repo_subscriptions
  has_many :issues,            through: :issue_assignments

  scope :public_profile, -> { where.not(users: { private: true }) }

  alias_attribute :token, :github_access_token

  delegate :for, to: :repo_subscriptions, prefix: true
  before_save :set_default_last_clicked_at

  def self.with_repo_subscriptions
    left_outer_joins(:repo_subscriptions)
      .where("repo_id is not null")
      .distinct
  end

  # users that are not subscribed to any repos
  def self.inactive
    joins("LEFT OUTER JOIN repo_subscriptions on users.id = repo_subscriptions.user_id").where("repo_subscriptions.user_id is null")
  end

  # We record when an email is sent out, which includes
  # the current day's email. When raw_emails_since_click = 1
  # then there have been zero emails missed.
  def emails_missed_since_click
    return 0 if raw_emails_since_click <= 0
    raw_emails_since_click - 1
  end

  # The `raw_streak_count` is the value stored in the
  # DB. This value should be updated when a user clicks on an
  # email.
  #
  # The `emails_missed_since_click` is updated every time
  # we send an email.
  #
  # The streak count is the prior saved streak minus the number
  # of emails the user has not clicked.
  def effective_streak_count
    value = raw_streak_count - emails_missed_since_click
    return 0 if value < 0
    return value
  end

  def record_click!(save: true)
    return if raw_emails_since_click.zero?

    self.raw_streak_count       = effective_streak_count + 1
    self.raw_emails_since_click = 0
    self.save! if save
  end

  def subscribe_docs!
    subscriptions = self.repo_subscriptions.order(Arel.sql('RANDOM()')).load
    DocMailerMaker.new(self, subscriptions) { |sub| sub.ready_for_next? }.deliver_later
  end

  def set_default_last_clicked_at
    self.last_clicked_at ||= Time.now
  end

  def own_repos_json(per_page = 100)
    repos_fetcher(GithubFetcher::Repos::OWNED, token: token, per_page: per_page.to_s).as_json
  end

  def starred_repos_json
    repos_fetcher(GithubFetcher::Repos::STARRED, token: token).as_json
  end

  def subscribed_repos_json
    repos_fetcher(GithubFetcher::Repos::SUBSCRIBED, token: token).as_json
  end

  def fetcher
    @fetcher ||= GithubFetcher::User.new(token: token)
  end

  def repos_fetcher(kind, options = {})
    GithubFetcher::Repos.new({ token: token, kind: kind }.merge(options))
  end

  def auth_is_valid?
    fetcher.valid?
  end

  @@max_id = nil

  # Much faster than order("RANDOM()") but it's
  # not guaranteed to return results
  def self.fast_rand
    @@max_id = self.maximum(:id) if @@max_id.nil?

    where("id >= ?", Random.new.rand(1..@@max_id))
  end

  def default_avatar_url
    "http://gravatar.com/avatar/default"
  end

  def account_delete_token
    if self[:account_delete_token].blank?
      self.account_delete_token = SecureRandom.hex(64)
      update_attribute(:account_delete_token, account_delete_token) unless new_record?
    end

    self[:account_delete_token]
  end

  def enqueue_inactive_email
    background_inactive_email(self.id)
  end

  def able_to_edit_repo?(repo)
    repo.user_name == github.downcase
  end

  def public?
    !private
  end

  def not_yet_subscribed_to?(repo)
    !subscribed_to?(repo)
  end

  def subscribed_to?(repo)
    sub_from_repo(repo).present?
  end

  def sub_from_repo(repo)
    self.repo_subscriptions.find_by(repo_id: repo.id)
  end

  def github_json
    fetcher.json
  end

  def fetch_avatar_url
    github_json["avatar_url"]
  end

  def set_avatar_url!
    self.avatar_url = self.fetch_avatar_url || default_avatar_url
    self.save!
  end

  def github_url
    "https://github.com/#{github}"
  end

  def valid_email?
    ValidateEmail.valid?(email)
  end

  def days_since_last_clicked
    return 0 if last_clicked_at.blank?
    (
      (Time.now - last_clicked_at) / 1.day
    ).ceil # only want whole days
  end

  def days_since_last_email
    last_sent_at = repo_subscriptions.where("last_sent_at is not null").order(:last_sent_at).first.try(:last_sent_at)
    last_sent_at ||= self.created_at
    (
      (Time.now - last_sent_at) / 1.day
    ).ceil # only want whole days
  end

  def favorite_language?(language)
    favorite_languages.include? language if favorite_languages
  end

  def has_favorite_languages?
    favorite_languages && !favorite_languages.empty?
  end

  def issue_assignments_to_deliver(assign: true)
    prior_assignments = issue_assignments.where(delivered: false).limit(daily_issue_limit)
    return prior_assignments unless prior_assignments.blank?

    issue_assigner.assign! if assign
    issue_assignments.where(delivered: false).limit(daily_issue_limit)
  end

  private

  def issue_assigner
    @issue_assigner ||= IssueAssigner.new(self, repo_subscriptions)
  end
end
