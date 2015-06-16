class LanguageSubscription < ActiveRecord::Base
  include ResqueDef

  validates  :language, uniqueness: { scope: :user_id }, presence: true
  validates  :user_id, presence: true
  validates  :email_limit, numericality: { less_than: 21, greater_than: 0 }

  belongs_to :user

  has_many   :issue_assignments
  has_many   :issues, through: :issue_assignments

  def self.get_issues
    repos = Repo.find_where(language: @language)
  end

end
