require 'test_helper'

class GithubFetcher::IssueCommentsTest < ActiveSupport::TestCase
  def comments_fetcher
    issue = issues(:issue_three)
    issue.repo = repos(:sinatra_sinatra) # For some reason, this isn't set :/

    GithubFetcher::IssueComments.new(
      owner_name: issue.owner_name,
      repo_name: issue.repo_name,
      number: issue.number
    )
  end

  test "quacks like a GithubFetcher::Resource" do
    fetcher = comments_fetcher
    GithubFetcher::Resource.instance_methods(false).each do |method|
      assert fetcher.respond_to? method, "Failed to respond_to? #{method}"
    end
    GithubFetcher::Resource.private_instance_methods(false).each do |method|
      assert fetcher.respond_to? method, "Failed to respond_to? #{method}"
    end
  end

  test "#as_json doesn't raise errors" do
    VCR.use_cassette "fetch_issue_comments" do
      assert_nothing_raised { comments_fetcher.as_json }
    end
  end

  test "#as_json returns list of comments" do
    first_comment_url = "https://api.github.com/repos/sinatra/sinatra/issues/comments/5"

    VCR.use_cassette "fetch_issue_comments" do
      assert_equal comments_fetcher.as_json.first['url'], first_comment_url
    end
  end

  test "#as_json returns [] when error" do
    GitHubBub.stub(:get, -> (_,_) { raise GitHubBub::RequestError }) do
      assert_equal comments_fetcher.as_json, {}
    end
  end

  test "#commenters returns list of unqiue commenters" do
    fetcher = comments_fetcher
    fetcher.stub(:as_json, -> { [
      { "id"=>5, "user"=> { "login"=>"rtomayko", "id"=>404 } },
      { "id"=>6, "user"=> { "login"=>"rtomayko", "id"=>404 } },
      { "id"=>7, "user"=> { "login"=>"DavidRagone", "id"=>22345 } },
    ] }) do
      assert_equal fetcher.commenters, ['rtomayko', 'DavidRagone']
    end
  end
end
