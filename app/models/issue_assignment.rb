class IssueAssignment < ActiveRecord::Base
  belongs_to :repo_subscription
  belongs_to :language_subscription
  has_one    :user, through: :repo_subscription

  belongs_to :issue
  has_one    :repo, through: :issue
  # validates  :repo_subscription_id, presence: true
  validates  :issue_id, uniqueness: { scope: :repo_subscription_id }, presence: true

end
