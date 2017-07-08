module GithubFetcher
  # Base class for resources accessible via GitHubBub
  class Resource
    # Often over-ridden by subclasses in order to set @api_path. When over-ridden,
    #   it's preferable to call `super` so as to set options as below (and get any
    #   other changes made to this base call in the future)
    def initialize(options)
      @options = options
    end

    # Generally not over-riden
    def as_json
      response.json_body
    end

    private

    attr_reader :api_path, :options

    # Generally not over-riden
    def response
      @response ||= begin
                      GitHubBub.get(api_path, options)
                    rescue GitHubBub::RequestError => e
                      # Error is passed, though not always used by subclasses
                      null_response(e)
                    end
    end

    # Sometimes over-ridden to use the error
    def null_response(error)
      GitHubBub::Response.new(body: null_response_body.to_json)
    end

    # Sometimes over-ridden to set a specific response when GitHubBub API call
    #   fails.
    def null_response_body
      {}
    end
  end
end
