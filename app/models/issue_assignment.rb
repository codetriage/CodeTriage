class IssueAssignment < ActiveRecord::Base
  belongs_to  :repo_subscription
  has_one     :user, :through => :repo_subscription
  has_one     :repo, :through => :repo_subscription
  has_one     :issue
end
