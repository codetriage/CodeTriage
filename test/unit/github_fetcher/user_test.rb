# frozen_string_literal: true

require "test_helper"

class GithubFetcher::UserTest < ActiveSupport::TestCase
  test "quacks like a GithubFetcher::Resource" do
    assert_kind_of GithubFetcher::Resource, GithubFetcher::User.new(token: "asdf")
  end

  test "#as_json returns user json" do
    expected_user_login = "DavidRagone"
    VCR.use_cassette "fetch_github_user" do
      user_fetcher = GithubFetcher::User.new(
        token: OmniAuth.config.mock_auth[:github][:credentials][:token]
      )

      assert_equal user_fetcher.as_json["login"],
        expected_user_login,
        "Failed: Got #{user_fetcher.as_json}"
    end
  end

  test "#as_json returns {} when error" do
    GitHubBub.stub(:get, ->(_, _) { raise GitHubBub::RequestError }) do
      user_fetcher = GithubFetcher::User.new(
        token: OmniAuth.config.mock_auth[:github][:credentials][:token]
      )

      assert_equal user_fetcher.as_json, {}
      assert_nil user_fetcher.as_json["title"], user_fetcher.as_json
    end
  end

  test "#valid? returns true if user token is valid" do
    VCR.use_cassette "fetch_github_user_valid_check" do
      user_fetcher = GithubFetcher::User.new(token: ENV["GITHUB_API_KEY"])

      assert user_fetcher.valid?
    end
  end

  test "#valid? returns false if user token is invalid" do
    VCR.use_cassette "fetch_github_user_invalid_check" do
      user_fetcher = GithubFetcher::User.new(token: "asdf")

      assert_not user_fetcher.valid?
    end
  end

  test "#valid? returns false when API error occurs" do
    GitHubBub.stub(:valid_token?, ->(_) { raise GitHubBub::RequestError }) do
      user_fetcher = GithubFetcher::User.new(token: "asdf")

      assert_not user_fetcher.valid?
    end
  end
end
