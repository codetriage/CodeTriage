# PORO
class IssueAssigner
  attr_reader :user, :subscriptions

  def initialize(user, subscriptions)
    @user          = user
    @subscriptions = subscriptions
  end

  def assign!
    subscriptions.each do |sub|
      assign_issues_for_sub(sub, email_limit: sub.email_limit)
    end
    self
  end

  private

  def assign_issues_for_sub(sub, email_limit:)
    issues = Issue.find_by_sql([%Q{
                SELECT
                  *
                FROM
                  issues
                WHERE
                  repo_id = :repo_id AND
                  state   = :repo_state
                  AND id NOT IN (
                    SELECT
                      issue_id
                    FROM
                      issue_assignments
                    WHERE
                      repo_subscription_id = :subscription_id
                  )
                ORDER BY
                  random()
                LIMIT
                  :email_limit
                }.freeze, {
                  repo_id:         sub.repo_id,
                  repo_state:      Issue::OPEN,
                  subscription_id: sub.id,
                  email_limit:     email_limit
                }]).first(email_limit)

    return false if issues.blank?

    issues.each do |issue|
      if issue.valid_for_user?(user)
        sub.issue_assignments.create(issue_id: issue.id)
      else
        # prevent selecting this issue again and try to find another one
        sub.issue_assignments.create(issue_id: issue.id, delivered: true) &&
          assign_issue_for_sub(sub, email_limit: 1) # yay recursion!
      end
    end
  end
end
