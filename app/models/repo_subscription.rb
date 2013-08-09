class RepoSubscription < ActiveRecord::Base
  include ResqueDef

  validates :repo_id, :uniqueness => {:scope => :user_id}

  belongs_to :repo
  belongs_to :user
  has_many   :issue_assignments

  has_many   :issues, :through => :issue_assignments

  validates :email_limit, numericality: {less_than: 21, greater_than: 0}

  def self.ready_for_triage
    where("last_sent_at is null or last_sent_at < ?", 23.hours.ago)
  end

  def ready_for_next?
    return true if last_sent_at.blank?
    last_sent_at < 24.hours.ago
  end

  def wait?
    !ready_for_next?
  end

  def send_triage_email!
    background_send_triage_email(self.id)
  end

  def self.queue_triage_emails!
    find_each(:conditions => ["last_sent_at is null or last_sent_at < ?", 23.hours.ago]) do |repo_sub|
      repo_sub.send_triage_email!
    end
  end

  # a list of all issues assigned to the current repo_sub
  def assigned_issue_ids
    @assigned_issue_ids ||= self.issues.map(&:id) + [-1]
  end

  def assign_multi_issues!
    self.email_limit.times.map do
      assign_issue!
    end
  end

  def get_issue_for_triage
    issue = repo.issues.where(:state => 'open').where("id not in (?)", assigned_issue_ids).all.sample
    return nil   if issue.blank?
    return issue if issue.valid_for_user?(self.user)

    # add issue to restricted list and try again
    assigned_issue_ids << issue.id
    get_issue_for_triage
  end

  def assign_issue!
    issue = get_issue_for_triage
    unless issue.blank?
      assignment = issue_assignments.new
      assignment.issue_id = issue.id
      assignment.user_id  = user.id
      assignment.save
    end
    return issue
  ensure
    self.update_attributes :last_sent_at => Time.now unless wait?
  end

  resque_def(:background_send_triage_email) do |id|
    repo_sub = RepoSubscription.includes(:user, :repo).where(:id => id).first
    issue    = repo_sub.assign_issue!
    UserMailer.send_triage(:repo => self.repo, :user => self.user, :issue => issue).deliver
  end
end
