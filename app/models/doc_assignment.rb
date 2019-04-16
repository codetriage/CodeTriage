# frozen_string_literal: true

class DocAssignment < ActiveRecord::Base
  belongs_to :repo_subscription
  belongs_to :doc_method, optional: true
  belongs_to :doc_class, optional: true

  delegate :user, to: :repo_subscription
end
