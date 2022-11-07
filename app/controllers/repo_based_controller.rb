# frozen_string_literal: true

class RepoBasedController < ApplicationController
  protected

  def name_from_params(options)
    [options[:name], options[:format]].compact.join('.')
  end

  def find_repo(options, only_active: true)
    repo = Repo
    repo = repo.active if only_active
    repo.find_by_full_name(options[:full_name].downcase)
  end
end
