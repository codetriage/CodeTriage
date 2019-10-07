# frozen_string_literal: true

require 'test_helper'

class GithubFetcher::EmailTest < ActiveSupport::TestCase
  test "quacks like a GithubFetcher::Resource" do
    assert_kind_of GithubFetcher::Resource, GithubFetcher::User.new(token: 'asdf')
  end

  test "#as_json includes list of emails for given user" do
    VCR.use_cassette "fetch_emails" do
      email_fetcher = GithubFetcher::Email.new(
        token: OmniAuth.config.mock_auth[:github][:credentials][:token]
      )

      assert_equal email_fetcher.as_json, [
        { "email" => "dmragone@gmail.com", "primary" => true, "verified" => true, "visibility" => "public" },
        { "email" => "david.ragone@hired.com", "primary" => false, "verified" => true, "visibility" => nil }
      ], "Failed: Got #{email_fetcher.as_json}"
    end
  end

  test "#as_json returns null response when bad request" do
    VCR.use_cassette "bad_fetch_emails" do
      email_fetcher = GithubFetcher::Email.new(token: 'asdf')

      assert_equal email_fetcher.as_json, { "message" => "Bad credentials", "documentation_url" => "https://developer.github.com/v3" }
    end
  end
end
