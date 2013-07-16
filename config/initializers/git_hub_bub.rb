
GitHubBub::Request::USER_AGENT = 'codetriage'
GitHubBub::Request::RETRIES    = 3
GitHubBub::Request::GITHUB_VERSION = "vnd.github.v3.full+json"

# Auth all non authed requests (due to github request limits)
GitHubBub::Request.set_before_callback do |request|
  if request.options.key?(:token) || request.token?
    # Request is authorized, do nothing
  else
    request.token = User.random.first.try(:token)
  end
end
