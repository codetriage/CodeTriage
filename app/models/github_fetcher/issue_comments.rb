module GithubFetcher
  class IssueComments < Resource
    def initialize(owner_name:, repo_name:, number:)
      @api_path = File.join(
        'repos',
        owner_name,
        repo_name,
        'issues',
        number.to_s,
        'comments'
      )
      super({})
    end

    def commenters
      as_json.collect { |comment| comment["user"]["login"] }.uniq
    end
  end
end
