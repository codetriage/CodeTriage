require 'test_helper'

class GithubFetcher::EmailTest < ActiveSupport::TestCase
  test "quacks like a GithubFetcher::Resource" do
    email_fetcher = GithubFetcher::Email.new(token: 'asdf')
    GithubFetcher::Resource.instance_methods(false).each do |method|
      assert email_fetcher.respond_to? method, "Failed to respond_to? #{method}"
    end
    GithubFetcher::Resource.private_instance_methods(false).each do |method|
      assert email_fetcher.respond_to? method, "Failed to respond_to? #{method}"
    end
  end

  test "#as_json includes list of emails for given user" do
    VCR.use_cassette "fetch_emails" do
      email_fetcher = GithubFetcher::Email.new(
        token: OmniAuth.config.mock_auth[:github][:credentials][:token]
      )

      assert email_fetcher.as_json == [
        {"email"=>"dmragone@gmail.com", "primary"=>true, "verified"=>true, "visibility"=>"public"},
        {"email"=>"david.ragone@hired.com", "primary"=>false, "verified"=>true, "visibility"=>nil}
      ], "Failed: Got #{email_fetcher.as_json}"
    end
  end

  test "#as_json returns null response when bad request" do
    VCR.use_cassette "bad_fetch_emails" do
      email_fetcher = GithubFetcher::Email.new(token: 'asdf')

      assert email_fetcher.as_json == [{}]
    end
  end
end
