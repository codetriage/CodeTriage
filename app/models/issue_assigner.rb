# frozen_string_literal: true

# PORO
# This class takes in a user and their subscriptions and generates IssueAssignment's for
# each of the subscriptions based on that subscription's `email_limit`
#
# Example:
#
#   user = User.first
#   assigner = IssueAssigner.new(user, user.repo_subscriptions)
#   assigner.assign!
#
class IssueAssigner
  attr_reader :user, :subscriptions

  def initialize(user, subscriptions)
    @user          = user
    @subscriptions = subscriptions
    @assigned_count_hash = Hash.new { |hash, key| hash[key] = 0 }
  end

  def assign!
    subscriptions.each do |sub|
      assign_issues_for_sub(sub)
    end

    self
  end

  private def stop?(sub)
    @assigned_count_hash[sub] >= sub.email_limit
  end

  private def assign_issues_for_sub(sub)
    issues = issues_for_sub(sub)

    return if issues.empty?

    issues.each do |issue|
      next if stop?(sub)

      if issue.valid_for_user?(user)
        sub.issue_assignments.create(issue_id: issue.id)
        @assigned_count_hash[sub] += 1
      else
        # prevent selecting this issue again and try to find another one
        sub.issue_assignments.create(issue_id: issue.id, delivered: true)
      end
    end

    assign_issues_for_sub(sub) unless stop?(sub)
  end

  private def issues_for_sub(sub)
    sql = <<~SQL
      SELECT
        id
      FROM
        issues
      WHERE
        repo_id = :repo_id and
        state   = :issue_state
        AND id NOT IN (
          SELECT
            issue_id
          FROM
            issue_assignments
          WHERE
            repo_subscription_id = :sub_id
        )
      ORDER BY
        random()
      LIMIT
        :email_limit
    SQL
    Issue.find_by_sql([sql, { sub_id: sub.id, issue_state: Issue::OPEN, repo_id: sub.repo_id, email_limit: sub.email_limit }]).first(sub.email_limit)
  end
end
