# frozen_string_literal: true

# http://stackoverflow.com/questions/3651860/which-characters-are-illegal-within-a-branch-name
class GitBranchnameGenerator
  def initialize(username:, doc_path:)
    @username = username
    @doc_path = doc_path
  end

  def branchname
    "#{@username}-update-docs-#{@doc_path}-for-pr".gsub(/[^a-zA-Z0-9\_]/, "-")
  end
end
