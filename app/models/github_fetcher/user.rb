module GithubFetcher
  class User < Resource
    def initialize(options)
      @api_path = '/user'
      super
    end

    def valid?
      response = GitHubBub.valid_token?(@options[:token])
      response.rate_limit_sleep! if response
      response
    end
  end
end
