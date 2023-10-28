# frozen_string_literal: true

require "test_helper"

class GithubFetcher::IssueTest < ActiveSupport::TestCase
  def issue_fetcher(issue)
    GithubFetcher::Issue.new(
      owner_name: issue.owner_name,
      repo_name: issue.repo_name,
      number: issue.number
    )
  end

  test "quacks like a GithubFetcher::Resource" do
    assert_kind_of GithubFetcher::Resource, GithubFetcher::User.new(token: "asdf")
  end

  test "#as_json includes issue details" do
    fetcher = issue_fetcher(issues(:issue_one))

    VCR.use_cassette "fetch_issue" do
      assert_equal fetcher.as_json["title"], "first test issue", fetcher.as_json
    end
  end

  test "#as_json returns {} when error" do
    GitHubBub.stub(:get, ->(_, _) { raise GitHubBub::RequestError }) do
      fetcher = issue_fetcher(issues(:issue_one))
      assert_nil fetcher.as_json["title"], fetcher.as_json
    end
  end
end
