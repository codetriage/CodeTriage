module GithubFetcher
  class Resource
    def initialize(options)
      @options = options
    end

    def as_json
      response.json_body
    end

    def response
      @response ||= begin
                      GitHubBub.get(api_path, options)
                    rescue GitHubBub::RequestError
                      null_response
                    end
    end

    private

    attr_reader :api_path, :options

    def null_response
      GitHubBub::Response.new(body: {}.to_json)
    end
  end
end
