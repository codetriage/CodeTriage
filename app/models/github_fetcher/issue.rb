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
  end
end
