# frozen_string_literal: true

class DocClass < ActiveRecord::Base
  belongs_to :repo
  has_many :doc_comments, dependent: :destroy
end
