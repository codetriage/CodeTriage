module GitHubBub
  class RequestError < StandardError; end

  class Request
    include HTTParty
    base_uri 'https://api.github.com'
    headers  'Accept' => 'application/vnd.github.3.raw+json', "User-Agent"=>"codetriage"

    def self.fetch(url, input_options = {})
      options = {}
      options[:query] = input_options
      3.times.retry do
        set_auth_from_token!(input_options)
        response = get_with_validations(url, options)
      end
    end

    def self.set_auth_from_token!(options)
      token = if options.has_key?(:token)
        options.delete(:token)
      else
        User.random.first.try(:token)
      end
      self.headers["Authorization"] = "token #{token}" if token.present?
    end

    def self.get_with_validations(url, options)
      url = "/#{url}" unless url =~ /^\//
      response = self.get(url, options)
      response = GitHubBub::Response.create(response)
      raise RequestError, response.json_body['message'] unless response.success?
      return response
    end
  end
end
