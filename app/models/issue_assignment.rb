class IssueAssignment < ActiveRecord::Base
  belongs_to :repo_subscription
  belongs_to :language_subscription

  belongs_to :issue
  has_one    :repo, through: :issue
  # validates  :repo_subscription_id, presence: true
  validates  :issue_id, uniqueness: { scope: :repo_subscription_id }, presence: true

  def user
    if language_subscription_id
      return language_subscription.user
    elsif repo_subscription_id
      return repo_subscription.user
    else
      return nil
    end
  end
end
