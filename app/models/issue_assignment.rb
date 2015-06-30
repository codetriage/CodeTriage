class IssueAssignment < ActiveRecord::Base
  belongs_to :repo_subscription
  belongs_to :language_subscription

  belongs_to :issue
  has_one    :repo, through: :issue
  # validates  :repo_subscription_id, presence: true
  validates  :issue_id, uniqueness: { scope: :repo_subscription_id }, presence: true, if: :is_repo_assignment?
  validates  :issue_id, uniqueness: { scope: :language_subscription_id }, presence: true, if: :is_language_assignment?

  def user
    if language_subscription_id
      return language_subscription.user
    elsif repo_subscription_id
      return repo_subscription.user
    else
      return nil
    end
  end

  def is_language_assignment?
    return repo_subscription_id.nil?
  end

  def is_repo_assignment?
    return language_subscription_id.nil?
  end
end
