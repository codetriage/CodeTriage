class IssueAssignment < ActiveRecord::Base
  belongs_to  :repo_subscription
  has_one     :user, :through => :repo_subscription
  has_one     :repo, :through => :repo_subscription
  belongs_to  :issue

  validates :issue_id, :uniqueness => { :scope => :user_id }


  validates_presence_of :user_id
  validates_presence_of :issue_id

end
