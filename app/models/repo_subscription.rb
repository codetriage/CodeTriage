class RepoSubscription < ActiveRecord::Base
  DEFAULT_READ_LIMIT  = 3
  DEFAULT_WRITE_LIMIT = 3


  validates  :repo_id, uniqueness: { scope: :user_id }, presence: true
  validates  :user_id, presence: true
  validates  :email_limit, numericality: { less_than: 21, greater_than_or_equal_to: 0 }

  belongs_to :repo
  belongs_to :user

  has_many   :issue_assignments
  has_many   :issues, through: :issue_assignments
  has_many   :doc_assignments

  before_save :set_read_write

  def set_read_write
    if read_limit.blank? || read_limit.zero?
      self.read = false
    else
      self.read = true
    end

    if write_limit.blank? || write_limit.zero?
      self.write = false
    else
      self.write = true
    end

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

  def pre_assigned_doc_method_ids
    self.doc_methods.map(&:id) + [-1]
  end

  def unassigned_read_doc_methods(limit = self.read_limit)
    repo.methods_with_docs.
         active.
         where("doc_methods.id not in (?)", pre_assigned_doc_method_ids).
         where(skip_read: false).
         order("random()").
         limit(limit || DEFAULT_READ_LIMIT)
  end

  def unassigned_write_doc_methods(limit = self.write_limit)
    doc_method_ids = self.doc_methods.map(&:id) + [-1]
    repo.methods_missing_docs.
         active.
         where("doc_methods.id not in (?)", pre_assigned_doc_method_ids).
         where(skip_write: false).
         order("random()").
         limit(limit || DEFAULT_WRITE_LIMIT)
  end

  def doc_methods
    DocMethod.where(id: doc_assignments.map(&:doc_method_id))
  end
  def self.for(repo_id)
    where(repo_id: repo_id)
  end
end
