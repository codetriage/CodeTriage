# PORO
class IssueAssigner
  attr_reader :user, :subscriptions

  def initialize(user, subscriptions)
    @user          = user
    @subscriptions = subscriptions
  end

  def assign
    subscriptions.each do |sub|
      sub.email_limit.times.map do
        assign_issue_for_sub(sub)
      end
    end
    self
  end

  private
    def assign_issue_for_sub(sub)
      issue = sub.repo.issues.where(state: 'open').where.not(id: sub.issues.pluck(:id) ).first
      return false if issue.blank?
      if issue.valid_for_user?(user)
        sub.issue_assignments.create!(issue_id: issue.id, user_id: user.id)
      else
        # prevent selecting this issue again and try to find another one
        sub.issue_assignments.create!(issue_id: issue.id, user_id: user.id, delivered: true)
        assign_issue_for_sub(sub) # yay recursion!
      end
    end
end
