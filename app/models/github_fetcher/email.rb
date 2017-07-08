module GithubFetcher
  class Email < Resource
    def initialize(options)
      super
      @api_path = '/user/emails'
    end

    private

    def null_response
      GitHubBub::Response.new(body: [{}].to_json)
    end
  end
end
