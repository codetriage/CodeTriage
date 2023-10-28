# frozen_string_literal: true

module GithubFetcher
  class Email < Resource
    def initialize(options)
      super
      @api_path = "/user/emails"
    end

    private

    def null_response_body
      [{}]
    end
  end
end
