class RepoSubscription < ActiveRecord::Base
  include ResqueDef

  validates  :repo_id, uniqueness: { scope: :user_id }, presence: true
  validates  :user_id, presence: true
  validates  :email_limit, numericality: { less_than: 21, greater_than: 0 }

  belongs_to :repo
  belongs_to :user

  has_many   :issue_assignments
  has_many   :issues, through: :issue_assignments

  def self.for(repo_id)
    where(repo_id: repo_id).includes(:issues)
  end

  resque_def(:background_send_triage_email) do |id|
    repo_sub = RepoSubscription.includes(:user, :repo).find(id)
    IssueAssigner.new(repo_sub.user, [repo_sub]).assign
    if assignment = repo_sub.user.issue_assignments.order(:created_at).last
      UserMailer.send_triage(repo: repo_sub.repo, user: repo_sub.user, assignment: assignment).deliver
    end
  end
end
