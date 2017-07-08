module GithubFetcher
  class Issues < Resource
    def initialize(options)
      @api_path = "/repos/#{options.delete(:user_name)}/#{options.delete(:name)}/issues"

      options[:sort]      ||= 'comments'
      options[:direction] ||= 'desc'
      options[:state]     ||= 'open'
      options[:page]      ||= 1

      super
    end

    def response
      @response ||= begin
                      GitHubBub.get(api_path, options)
                    rescue GitHubBub::RequestError => e
                      NullIssuesResponse.new(e)
                    end
    end
  end

  class NullIssuesResponse
    attr_reader :error

    def initialize(error)
      @error = error
    end
  end
end
