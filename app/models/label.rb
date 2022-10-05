class Label < ActiveRecord::Base
  has_many :repo_labels
  has_many :repos, through: :repo_lables
end
