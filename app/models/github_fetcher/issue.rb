module GithubFetcher
  class Issue < Resource
    def initialize(owner_name:, repo_name:, number:)
      @api_path = File.join(
        'repos',
        owner_name,
        repo_name,
        'issues',
        number.to_s
      )
      super({})
    end

    # TODO - make distinct resource?
    def commenters_as_json
      begin
        response = GitHubBub.get(File.join(api_path, "/comments")).json_body
        response.collect{ |comment| comment["user"]["login"] }.uniq
      rescue GitHubBub::RequestError
        []
      end
    end
  end
end
