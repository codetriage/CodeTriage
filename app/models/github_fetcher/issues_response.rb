module GithubFetcher
  class IssuesResponse
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def each
      response.json_body
    end

    def more_issues?
      !response.last_page?
    end

    def exists?
      true
    end
  end
end
