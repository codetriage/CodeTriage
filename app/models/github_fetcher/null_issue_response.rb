module GithubFetcher
  class NullIssueResponse
    def each
      []
    end

    def more_issues?
      false
    end

    def exists?
      false
    end
  end
end
