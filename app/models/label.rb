class Label < ActiveRecord::Base
	 belongs_to :repo
	 has_many :issue_labels
	 has_many :issues, through: :issue_labels

	 validates :name, :repo_id, presence: true
end
