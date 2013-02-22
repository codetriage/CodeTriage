module GitHubBub
  class Request
    include HTTParty
    base_uri 'https://api.github.com'
    headers  'Accept' => 'application/vnd.github.3.raw+json'

    def self.fetch(url, input_options = {})
      options = {}
      input_options ||= {}

      token = input_options.delete(:token)

      options[:query] = input_options
      url = "/#{url}" unless url =~ /^\//

      self.headers["Authorization"] = "token #{token}" if token.present?

      response    = self.get(url, options)
      GitHubBub::Response.create(response)
    end
  end
end
