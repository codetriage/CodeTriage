# frozen_string_literal: true

module GithubFetcher
  class Repos < Resource
    KINDS = [
      OWNED = "repos",
      STARRED = "starred",
      SUBSCRIBED = "subscriptions"
    ]

    def initialize(options)
      unless options[:kind].in? KINDS
        raise TypeError.new("kind must be one of #{KINDS.join(", ")} (#{options[:kind]} invalid)")
      end

      options[:type] = "owner" if options[:kind] == OWNED

      @api_path = File.join(
        "user",
        options.delete(:kind)
      )
      super
    end
  end
end
