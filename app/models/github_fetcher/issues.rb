# frozen_string_literal: true

module GithubFetcher
  class Issues < Resource
    def initialize(options)
      @api_path = File.join(
        "repos",
        options.delete(:user_name),
        options.delete(:name),
        "issues"
      )

      options[:sort] ||= "comments"
      options[:direction] ||= "desc"
      options[:state] ||= "open"
      options[:page] ||= 1

      super
    end
  end
end
