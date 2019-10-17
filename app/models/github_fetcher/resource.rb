# frozen_string_literal: true

module GithubFetcher
  # Base class for resources accessible via GitHubBub
  class Resource
    attr_reader :error_message, :page

    # Often over-ridden by subclasses in order to set @api_path. When over-ridden,
    #   it's preferable to call `super` so as to set options as below (and get any
    #   other changes made to this base call in the future)
    def initialize(options)
      @options = options
      reset!
    end

    def call(retry_on_bad_token: false)
      resp = response

      return resp unless bad_token?
      return resp unless retry_on_bad_token

      unless retry_on_bad_token.is_a?(Integer)
        raise "retry_on_bad_token must be a number but is #{retry_on_bad_token.class}: #{retry_on_bad_token.inspect}"
      end

      return resp if retry_on_bad_token <= 0

      reset!
      call(retry_on_bad_token: retry_on_bad_token - 1)
    end

    # Generally not over-ridden
    def as_json
      @as_json ||= response.json_body
    end

    # Generally not over-ridden
    def response
      @response ||= begin
                      GitHubBub.get(api_path, options)
                    rescue GitHubBub::RequestError => e
                      @error = e
                      @error_message = e.message
                      null_response(e)
                    end
    end

    def success?
      return true if response.status.to_s.start_with?("2")

      @error = @error_message = "Status: #{response.status} body: #{response.body}"
      false
    end

    def bad_token?
      if response.status == 401 && response.body.match?(/Bad credentials/)
        @error = @error_message = "Bad credentials"
        return true
      end
      false
    end

    def error?
      # Ensure API request has been made (by calling `as_json` before returning
      #   error if it happened. `as_json` should always evaluate truthily, but
      #   @error will be false unless there's an error in the API request
      bad_token? || !success? || @error
    end

    def page=(number)
      reset!
      options[:page] = number
      @page = number
    end

    def last_page?
      response.last_page?
    end

    private

    private def reset!
      @response = nil
      @as_json = nil
      @error = nil
      @error_message = nil
    end

    attr_reader :api_path, :options

    # Sometimes over-ridden to use the error
    private def null_response(_error)
      GitHubBub::Response.new(body: null_response_body.to_json)
    end

    # Sometimes over-ridden to set a specific response when GitHubBub API call
    #   fails.
    private def null_response_body
      {}
    end
  end
end
