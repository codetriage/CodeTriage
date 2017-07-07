module GithubFetcher
  class User
    attr_reader :token

    def initialize(token)
      @token = token
    end

    def json
      GitHubBub.get(api_path, token: token).json_body
    end

    def valid?
      GitHubBub.valid_token?(token)
    end

    def emails
      GitHubBub.get("/user/emails", token: token).json_body
    end

    private

    def api_path
      "/user"
    end
  end
end
