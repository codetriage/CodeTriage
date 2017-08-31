module GithubFetcher
  # Base class for resources accessible via GitHubBub
  class Resource
    attr_reader :error_message, :page

    # Often over-ridden by subclasses in order to set @api_path. When over-ridden,
    #   it's preferable to call `super` so as to set options as below (and get any
    #   other changes made to this base call in the future)
    def initialize(options)
      @options = options
    end

    # Generally not over-ridden
    def as_json
      @as_json ||= response.json_body
    end

    # Generally not over-ridden
    def response
      @response ||= begin
                      response = GitHubBub.get(api_path, options)
                      response.rate_limit_sleep!
                      unless response.success?
                        @error         = true
                        @error_message = "Expecting a 2.x.x response but status was #{response.status}"
                        response       = null_response(response.body, status: response.status)
                      end
                      response
                    rescue => e
                      @error = e
                      @error_message = e.message
                      null_response(e)
                    end
    end

    def error?
      # Ensure API request has been made (by calling `as_json` before returning
      #   error if it happened. `as_json` should always evaluate truthily, but
      #   @error will be false unless there's an error in the API request
      as_json && @error
    end

    def page=(number)
      @response = nil
      @as_json = nil
      options[:page] = number
      @page = number
    end

    def last_page?
      response.last_page?
    end

    private

    attr_reader :api_path, :options

    # Sometimes over-ridden to use the error
    def null_response(_error, status: nil)
      GitHubBub::Response.new(body: null_response_body.to_json, status: status)
    end

    # Sometimes over-ridden to set a specific response when GitHubBub API call
    #   fails.
    def null_response_body
      {}
    end
  end
end
