class RepoSubscription < ActiveRecord::Base
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
end
