module GithubFetcher
  class Issues < Resource
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

    private

    def null_response(error)
      NullIssuesResponse.new(error)
    end
  end

  class NullIssuesResponse
    attr_reader :error, :error_message

    def initialize(error)
      @error = error
      @error_message = error.message
    end
  end
end
