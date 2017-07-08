require 'test_helper'

class GithubFetcher::RepoTest < ActiveSupport::TestCase
  def fetcher(repo)
    GithubFetcher::Repo.new(user_name: repo.user_name, name: repo.name)
  end

  test "quacks like a GithubFetcher::Resource" do
    fetcher = fetcher(repos(:issue_triage_sandbox))
    GithubFetcher::Resource.instance_methods(false).each do |method|
      assert fetcher.respond_to? method, "Failed to respond_to? #{method}"
    end
    GithubFetcher::Resource.private_instance_methods(false).each do |method|
      assert fetcher.respond_to? method, "Failed to respond_to? #{method}"
    end
  end

  test "#as_json doesn't raise errors" do
  end
end
