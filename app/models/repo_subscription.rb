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

  def self.for(repo_id)
    where(:repo_id => repo_id).includes(:issues)
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

    assigned_issue_ids << issue.id
    if issue.valid_for_user?(self.user)
      return issue
    else
      get_issue_for_triage
    end
  end

  def assign_issue!
    issue = get_issue_for_triage
    return false if issue.blank?
    assignment          = issue_assignments.new
    assignment.issue_id = issue.id
    assignment.user_id  = user.id

    return issue if assignment.save
  ensure
    self.update_attributes :last_sent_at => Time.now unless wait?
  end

  resque_def(:background_send_triage_email) do |id|
    repo_sub = RepoSubscription.includes(:user, :repo).where(:id => id).first
    issue    = repo_sub.assign_issue!
    UserMailer.send_triage(:repo => repo_sub.repo, :user => repo_sub.user, :issue => issue).deliver unless issue.blank?
  end
end
