module GithubFetcher
  class Issues < Resource
    attr_reader :error_message

    def initialize(options)
      @api_path = File.join(
        'repos',
        options.delete(:user_name),
        options.delete(:name),
        'issues'
      )

      options[:sort]      ||= 'comments'
      options[:direction] ||= 'desc'
      options[:state]     ||= 'open'
      options[:page]      ||= 1

      super
    end

    # TODO - test
    def more_issues?
      !response.last_page?
    end

    # TODO - test
    def error?
      # Ensure API request has been made (by calling `as_json` before returning
      #   error if it happened. `as_json` should always evaluate truthily, but
      #   @error will be false unless there's an error in the API request
      as_json && @error
    end

    private

    def null_response(error)
      # Not ideal place for side effects, really :/
      @error = true
      @error_message = error.message

      super
    end
  end
end
