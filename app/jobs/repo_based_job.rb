# frozen_string_literal: true

# The purpose of this class is to provide
# a base class that any job that needs to accept
# a repo can use.
#
# This class allows a job to either take an
# ActiveRecord instance or a repo integer
#
# The context of which repo the job is working
# on will be automatically added to scout
#
# Example:
#
#   class PrintRepoFullNameJob < RepoBasedJob
#     def perform(repo)
#       puts repo.full_name
#     end
#   end
#
#  repo = Repo.where(full_name: "rails/rails").first
#  PrintRepoFullNameJob.perform_now(repo)
#  # => "rails/rails"
#
#  repo_id = repo.id
#  PrintRepoFullNameJob.perform_now(repo_id)
#  # => "rails/rails"
class RepoBasedJob < ApplicationJob
  around_perform do |job, block|
    repo_or_id = job.arguments[0]
    if repo_or_id.is_a?(Integer)
      repo = Repo.find(repo_or_id)
    else
      repo = repo_or_id
    end
    job.arguments[0] = repo
    ScoutApm::Context.add(repo_id: repo.id)

    block.call
  end
end
