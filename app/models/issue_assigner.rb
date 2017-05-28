# PORO
class IssueAssigner
  attr_reader :user, :subscriptions

  def initialize(user, subscriptions)
    @user          = user
    @subscriptions = subscriptions
  end

  def assign!
    subscriptions.each do |sub|
      sub.email_limit.times.map do
        assign_issue_for_sub(sub)
      end
    end
    self
  end

  private
    def assign_issue_for_sub(sub)
      issue = Issue.find_by_sql(<<-SQL
                SELECT
                  *
                FROM
                  issues
                WHERE
                  repo_id = '#{sub.repo_id}'
                  AND id NOT IN (
                    SELECT
                      issue_id
                    FROM
                      issue_assignments
                    WHERE
                      repo_subscription_id = '#{sub.id}'
                  )
                ORDER BY
                  random()
                LIMIT
                  1
                SQL
              ).first

      return false if issue.blank?
      if issue.valid_for_user?(user)
        sub.issue_assignments.create!(issue_id: issue.id)
      else
        # prevent selecting this issue again and try to find another one
        sub.issue_assignments.create!(issue_id: issue.id, delivered: true)
        assign_issue_for_sub(sub) # yay recursion!
      end
    end
end
