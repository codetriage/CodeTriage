# frozen_string_literal: true

# I know it's awful but I don't have time to fix the GitHubBub API and this makes `rails c` not noisey
GitHubBub::Request.send(:remove_const, :GITHUB_VERSION)
GitHubBub::Request.send(:remove_const, :USER_AGENT)
GitHubBub::Request.send(:remove_const, :RETRIES)

GitHubBub::Request::GITHUB_VERSION = 'vnd.github.v3.full+json'
GitHubBub::Request::USER_AGENT = 'codetriage'
GitHubBub::Request::RETRIES = 3

# Auth all non authed requests (due to github request limits)
GitHubBub::Request.set_before_callback do |request|
  if request.token?
    # Request is authorized, do nothing
  else
    request.token = ENV['GITHUB_API_KEY'] || User.random.where.not(token: nil).first.try(:token)
  end
end
