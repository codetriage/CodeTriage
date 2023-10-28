# frozen_string_literal: true

# PORO
# This class takes in a repo and fetch all labels for that repo. It then
# creates labels and associates them with the passed in repo
#
# Example:
#
#   repo = Repo.first
#   assigner = RepoLabelAssigner.new(repo: repo)
#   assigner.create_and_associate_labels!
#
class RepoLabelAssigner
  def initialize(repo:)
    @repo = repo
    url = ["repos", repo.user_name, repo.name, "labels"].join("/")
    @github_bub_response = GitHubBub.get(url)
  end

  def create_and_associate_labels!
    return unless github_bub_response.success?

    remote_labels.each do |label_hash|
      label_name = label_hash["name"].downcase
      label = Label.where(name: label_name).first_or_create!
      repo.repo_labels.where(label: label).first_or_create
    end
  end

  private

  attr_reader :github_bub_response, :repo

  def remote_labels
    Array(github_bub_response.json_body)
  end
end
