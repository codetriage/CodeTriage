class LanguageSubscription < ActiveRecord::Base
  include ResqueDef

  validates  :language, uniqueness: { scope: :user_id }, presence: true
  validates  :user_id, presence: true
  validates  :email_limit, numericality: { less_than: 21, greater_than: 0 }

  validate   :language_exists

  belongs_to :user

  has_many   :issue_assignments
  has_many   :issues, through: :issue_assignments

  #gets a random issue from a random repo in the language // needs improvement
  def get_issues
    repos = Repo.where(language: language).order("RANDOM()")
    repos.each do |r|
      invalid_issues = user.issue_assignments.pluck(:issue_id)
      issues = Issue.where(state: "open").where.not(id: invalid_issues).order("RANDOM()")
      issues.each do |i|
        if i.valid_for_user? user
          return issue_assignments.create! issue_id: i.id
        else
          issue_assignments.create! issue_id: i.id, delivered: true
        end
      end
    end
    return false
  end

  def language_exists
    errors.add(:language, "does not exists") unless Repo.exists?(language: language)
  end

  resque_def(:background_send_language_email) do |id|
    language_sub = LanguageSubscription.includes(:user).find(id)
    if assignment = language_sub.get_issues
      assignment.update!(delivered: true)
      UserMailer.send_triage(repo: assignment.repo, user: language_sub.user, assignment: assignment, language: language_sub.language).deliver_now
    end
  end

end
