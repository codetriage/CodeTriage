# frozen_string_literal: true

class RepoSubscription < ActiveRecord::Base
  DEFAULT_READ_LIMIT = 3
  DEFAULT_WRITE_LIMIT = 3
  DOC_SUBSCRIBE_MIN_ACCOUNT_AGE = 7.days
  DOC_ACTIVITY_WINDOW = 60.days

  validates :repo_id, uniqueness: {scope: :user_id}, presence: true
  validates :user_id, presence: true
  validates :email_limit, numericality: {less_than: 21, greater_than_or_equal_to: 0}
  validate :doc_subscription_allowed, if: :newly_enabling_docs?

  belongs_to :repo, counter_cache: :subscribers_count, touch: true
  belongs_to :user

  has_many :issue_assignments
  has_many :issues, through: :issue_assignments
  has_many :doc_assignments

  scope :docs, -> { where(read: true).or(where(write: true)) }
  scope :active_docs, -> { docs.where("docs_last_click_at > ?", DOC_ACTIVITY_WINDOW.ago) }
  scope :inactive_docs_needing_reopt_in, lambda {
    docs.where("docs_last_click_at <= ?", DOC_ACTIVITY_WINDOW.ago)
      .where(docs_reopt_in_sent_at: nil)
  }

  before_save :set_read_write
  before_save :seed_docs_last_click_at

  def set_read_write
    self.read = !(read_limit.blank? || read_limit.zero?)

    self.write = !(write_limit.blank? || write_limit.zero?)

    true
  end

  def self.ready_for_docs
    where("last_sent_at is null or last_sent_at < ?", 23.hours.ago)
  end

  def ready_for_next?
    return true if last_sent_at.blank?
    last_sent_at < 8.hours.ago
  end

  def not_ready_for_next?
    !ready_for_next?
  end

  def unassigned_read_doc_methods(limit = read_limit)
    docs = repo.methods_with_docs
    if doc_assignments.any?
      docs = docs.where("doc_methods.id NOT IN (?)", doc_assignments.select(:doc_method_id))
    end

    docs
      .active
      .where(skip_read: false)
      .order(Arel.sql("RANDOM()"))
      .limit(limit || DEFAULT_READ_LIMIT)
  end

  def unassigned_write_doc_methods(limit = write_limit)
    docs = repo.methods_missing_docs
    if doc_assignments.any?
      docs = docs.where("doc_methods.id NOT IN (?)", doc_assignments.select(:doc_method_id))
    end

    docs
      .active
      .where(skip_write: false)
      .order(Arel.sql("RANDOM()"))
      .limit(limit || DEFAULT_WRITE_LIMIT)
  end

  def doc_methods
    DocMethod.where(id: doc_assignments.select(:doc_method_id))
  end

  def self.for(repo_id)
    where(repo_id: repo_id)
  end

  def seed_docs_last_click_at
    if (read || write) && docs_last_click_at.nil?
      self.docs_last_click_at = Time.now
    end
    true
  end

  private

  # The gate fires only when a subscription is newly becoming a doc sub. We read
  # intent from the incoming limits (mirroring set_read_write) because the
  # read/write booleans are not recomputed until the before_save callback, which
  # runs after validation.
  def newly_enabling_docs?
    will_be_doc_subscription? && !was_doc_subscription?
  end

  def will_be_doc_subscription?
    doc_limit?(read_limit) || doc_limit?(write_limit)
  end

  def was_doc_subscription?
    !!read_in_database || !!write_in_database
  end

  def doc_limit?(limit)
    !(limit.blank? || limit.zero?)
  end

  def doc_subscription_allowed
    return if user && user.created_at <= DOC_SUBSCRIBE_MIN_ACCOUNT_AGE.ago
    return if repo && repo.repo_subscriptions.active_docs.where.not(id: id).exists?

    errors.add(:base, "You can turn on docs once your account is 7 days old, or if this repo already has active doc subscribers.")
  end
end
