# frozen_string_literal: true

class RepoLabel < ActiveRecord::Base
  belongs_to :repo
  belongs_to :label
end
