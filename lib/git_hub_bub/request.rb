module GitHubBub
  class Request
    include HTTParty
    base_uri 'https://api.github.com'
    headers  'Accept' => 'application/vnd.github.3.raw+json'

    def self.fetch(url, input_options = {}, current_user = nil)
      options = {}
      input_options ||= {}

      token = input_options.delete(:token)
      token ||= current_user.github_access_token if current_user

      options[:query] = input_options
      url = "/#{url}" unless url =~ /^\//

      self.headers["Authorization"] = "token #{token}" if token.present?

      response    = self.get(url, options)
      GitHubBub::Response.create(response)
    end
  end
end
