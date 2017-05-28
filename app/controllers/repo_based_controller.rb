class RepoBasedController < ApplicationController
  protected

  def name_from_params(options)
    [options[:name], options[:format]].compact.join('.')
  end

  def find_repo(options)
    if repo = Repo.find_by_full_name(options[:full_name])
      repo.update_repo_info! if repo.updated_at < (Time.now - 6.hours)
    end

    repo
  end
end
