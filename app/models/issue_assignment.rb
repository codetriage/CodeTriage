class IssueAssignment < ActiveRecord::Base
  belongs_to  :repo_subscription
  has_one     :user, :through => :repo_subscription
  has_one     :repo, :through => :repo_subscription
  belongs_to  :issue
  validates :repo_subscription_id, presence: true
  validates :issue_id, :uniqueness => { :scope => :repo_subscription_id }, presence: true
end
