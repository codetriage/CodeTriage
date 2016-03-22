class DocAssignment < ActiveRecord::Base
  belongs_to :repo_subscription
  has_one :doc_method
  has_one :doc_class
end
