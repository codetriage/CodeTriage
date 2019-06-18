# frozen_string_literal: true

module GithubFetcher
  class User < Resource
    def initialize(options)
      @api_path = '/user'
      super
    end

    def valid?
      begin
        GitHubBub.valid_token?(@options[:token])
      rescue GitHubBub::RequestError
        false
      end
    end
  end
end
