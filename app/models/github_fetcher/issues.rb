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

    def more_issues?
      !response.last_page?
    end
  end
end
