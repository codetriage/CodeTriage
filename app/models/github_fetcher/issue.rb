module GithubFetcher
  class Issue
    attr_reader :api_path

    def initialize(issue)
      @api_path = "/repos/#{issue.owner_name}/#{issue.repo_name}/issues/#{issue.number}"
    end

    def issue_json
      GitHubBub.get(api_path).json_body
    end

    def commenters
      response = GitHubBub.get(File.join(api_path, "/comments")).json_body
      response.collect{ |comment| comment["user"]["login"] }.uniq
    end
  end
end
