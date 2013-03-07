module GitHubBub
  class Request
    include HTTParty
    base_uri 'https://api.github.com'
    headers  'Accept' => 'application/vnd.github.3.raw+json'

    def self.fetch(url, input_options = {})
      options = {}

      token = input_options.delete(:token) || User.random.first.try(:token)

      options[:query] = input_options
      url = "/#{url}" unless url =~ /^\//

      self.headers["Authorization"] = "token #{token}" if token.present?

      response    = self.get(url, options)
      gh_resp = GitHubBub::Response.create(response)
      raise RequestError, gh_resp.json_body['message'] unless gh_resp.success?
      gh_resp
    end
  end

  class RequestError < Exception
  end
end
