class RepoSubscription < ActiveRecord::Base
  validate :repo_id, :uniqueness => {:scope => :user_id}
  belongs_to :repo
  belongs_to :user
end
