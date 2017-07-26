module GithubFetcher
  class CommitSha < Resource
    def initialize(user_name:, name:, default_branch:)
      @api_path = File.join(
        'repos',
        user_name,
        name,
        'commits',
        default_branch || "master"
      )
      super({})
    end

    def commit_sha
      @commit_sha ||= as_json['sha']
    end
  end
end
