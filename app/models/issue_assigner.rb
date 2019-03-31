# frozen_string_literal: true

# PORO
class IssueAssigner
  attr_reader :user, :subscriptions

  def initialize(user, subscriptions)
    @user          = user
    @subscriptions = subscriptions
  end

  def assign!
    subscriptions.each do |sub|
      Array.new(sub.email_limit) do
        assign_issue_for_sub(sub)
      end
    end
    self
  end

  private

  def assign_issue_for_sub(sub)
    issue = Issue.where(repo_id: sub.repo_id, state: Issue::OPEN)
                 .where.not(id: IssueAssignment.select(:issue_id).where(repo_subscription_id: sub.id))
                 .order(Arel.sql('RANDOM()'))
                 .first

    return false if issue.blank?
    if issue.valid_for_user?(user)
      sub.issue_assignments.create(issue_id: issue.id)
    else
      # prevent selecting this issue again and try to find another one
      sub.issue_assignments.create(issue_id: issue.id, delivered: true) &&
        assign_issue_for_sub(sub) # yay recursion!
    end
  end
end
