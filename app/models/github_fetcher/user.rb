module GithubFetcher
  class User < Resource
    def initialize
      super
      @api_path = '/user'
    end

    def valid?
      begin
        GitHubBub.valid_token?(@options[:token])
      rescue GitHubBub::RequestError
        null_response
      end
    end
  end
end
