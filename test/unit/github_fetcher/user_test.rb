require 'test_helper'

class GithubFetcher::UserTest < ActiveSupport::TestCase
  test "quacks like a GithubFetcher::Resource" do
    fetcher = GithubFetcher::User.new(token: 'asdf')
    GithubFetcher::Resource.instance_methods(false).each do |method|
      assert fetcher.respond_to? method, "Failed to respond_to? #{method}"
    end
    GithubFetcher::Resource.private_instance_methods(false).each do |method|
      assert fetcher.respond_to? method, "Failed to respond_to? #{method}"
    end
  end

  test "#as_json returns user json" do
    VCR.use_cassette "fetch_github_user" do
      user_fetcher = GithubFetcher::User.new(
        token: OmniAuth.config.mock_auth[:github][:credentials][:token]
      )

      assert_equal user_fetcher.as_json, [
      ], "Failed: Got #{user_fetcher.as_json}"
    end
  end

  test "#as_json returns {} when error" do
    GitHubBub.stub(:get, -> (_, _) { raise GitHubBub::RequestError }) do
      user_fetcher = GithubFetcher::User.new(
        token: OmniAuth.config.mock_auth[:github][:credentials][:token]
      )

      assert_equal user_fetcher.as_json, {}
      assert_equal user_fetcher.as_json['title'], nil, user_fetcher.as_json
    end
  end

  test "#valid? returns true if user token is valid" do
    VCR.use_cassette "fetch_github_user" do
      user_fetcher = GithubFetcher::User.new(
        token: OmniAuth.config.mock_auth[:github][:credentials][:token]
      )

      assert user_fetcher.valid?
    end
  end
end
