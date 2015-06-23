class LanguageSubscription < ActiveRecord::Base
  include ResqueDef

  validates  :language, uniqueness: { scope: :user_id }, presence: true
  validates  :user_id, presence: true
  validates  :email_limit, numericality: { less_than: 21, greater_than: 0 }

  validate   :language_exists

  belongs_to :user

  has_many   :issue_assignments
  has_many   :issues, through: :issue_assignments

  #gets a random issue from a random repo in the language
  def get_issues
    tried_repo = []
    issue = false
    while true
      repo = Repo.where(language: language).where.not(id: tried_repo).order("RANDOM()").first
      return false if repo.nil?
      invalid_issues = user.issue_assignments.pluck(:issue_id)
      issue = repo.issues.where.not(id: invalid_issues).order("RANDOM()").first
      break unless issue.nil?
      tried_repo << repo.id
    end
    issue
  end

  def language_exists
    errors.add(:language, "does not exists") unless Repo.exists?(language: language)
  end

end
