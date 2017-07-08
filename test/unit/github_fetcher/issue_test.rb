require 'test_helper'

class GithubFetcher::IssueTest < ActiveSupport::TestCase
  def issue_fetcher(issue)
    GithubFetcher::Issue.new(
      owner_name: issue.owner_name,
      repo_name: issue.repo_name,
      number: issue.number
    )
  end

  test "quacks like a GithubFetcher::Resource" do
    fetcher = issue_fetcher(issues(:issue_one))
    GithubFetcher::Resource.instance_methods(false).each do |method|
      assert fetcher.respond_to? method, "Failed to respond_to? #{method}"
    end
    GithubFetcher::Resource.private_instance_methods(false).each do |method|
      assert fetcher.respond_to? method, "Failed to respond_to? #{method}"
    end
  end

  test "#as_json doesn't raise errors" do
    VCR.use_cassette "fetch_issue" do
      assert_nothing_raised { issue_fetcher(issues(:issue_one)).as_json }
    end
  end

  test "#as_json includes issue details" do
    fetcher = issue_fetcher(issues(:issue_one))

    VCR.use_cassette "fetch_issue" do
      assert_equal fetcher.as_json['title'], 'first test issue', fetcher.as_json
    end
  end

  test "#as_json returns {} when error" do
    GitHubBub.stub(:get, -> (_, _) { raise GitHubBub::RequestError }) do
      fetcher = issue_fetcher(issues(:issue_one))
      assert_nil fetcher.as_json['title'], fetcher.as_json
    end
  end

  test "#commenters_as_json returns list of unique comments" do
    issue = issues(:issue_three)
    issue.repo = repos(:sinatra_sinatra) # For some reason, this isn't set :/
    fetcher = issue_fetcher(issue)

    VCR.use_cassette "fetch_issue_commenters" do
      assert_equal fetcher.commenters_as_json, ["rtomayko"], fetcher.commenters_as_json
    end
  end

  test "#commenters_as_json returns [] when error" do
    GitHubBub.stub(:get, -> (_) { raise GitHubBub::RequestError }) do
      issue = issues(:issue_three)
      issue.repo = repos(:sinatra_sinatra) # For some reason, this isn't set :/
      fetcher = issue_fetcher(issue)

      assert_equal fetcher.commenters_as_json, []
    end
  end
end
