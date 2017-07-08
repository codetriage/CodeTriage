require 'test_helper'

class GithubFetcher::IssuesTest < ActiveSupport::TestCase
  def fetcher(repo)
    GithubFetcher::Issues.new(user_name: repo.user_name, name: repo.name)
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
    VCR.use_cassette "issue_triage_sandbox_fetch_issues" do
      assert_nothing_raised { fetcher(repos(:issue_triage_sandbox)).as_json }
    end
  end

  test "#as_json returns first page of open issues, sorted by comments desc (by default)" do
    fetcher = fetcher(repos(:rails_rails))

    VCR.use_cassette "rails_rails_fetch_issues" do
      as_json = fetcher.as_json
      assert as_json.size == 30, as_json
      assert as_json.first['title'] == "Missing helper file helpers//Users/xxxx/"\
        "Sites/xxxx/app/helpers/application_helper.rb_helper.rb"
      assert as_json.last['title'] == "Provide a default Content Security Policy "\
        "(CSP) that is lenient yet secure"
    end
  end

  test "#as_json can get second page of issues" do
    repo = repos(:rails_rails)
    fetcher = GithubFetcher::Issues.new(user_name: repo.user_name, name: repo.name, page: 2)

    VCR.use_cassette "rails_rails_fetch_issues_page_two" do
      as_json = fetcher.as_json
      assert as_json.size == 30, as_json
      assert as_json.first['title'] == "Give clients a way to refer to ActionDispatch "\
        "middleware classes without triggering an early load of ActionDispatch"
      assert as_json.last['title'] == "default_scope breaks chained having "\
        "statements in rails4"
    end
  end
end
