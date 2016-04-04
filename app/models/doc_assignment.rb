class DocAssignment < ActiveRecord::Base
  belongs_to :repo_subscription
  belongs_to :doc_method
  belongs_to :doc_class

  delegate :user, to: :repo_subscription
end
