require 'test_helper'

class GithubFetcher::IssuesTest < ActiveSupport::TestCase
  def fetcher(repo)
    GithubFetcher::Issues.new(user_name: repo.user_name, name: repo.name)
  end

  test "quacks like a GithubFetcher::Resource" do
    assert_kind_of GithubFetcher::Resource, GithubFetcher::User.new(token: 'asdf')
  end

  test "#as_json returns first page of open issues, sorted by comments desc (by default)" do
    fetcher = fetcher(repos(:rails_rails))

    VCR.use_cassette "rails_rails_fetch_issues" do
      as_json = fetcher.as_json
      assert_equal as_json.size, 30, as_json
      assert_equal as_json.first['title'], "Missing helper file helpers//Users/xxxx/"\
        "Sites/xxxx/app/helpers/application_helper.rb_helper.rb"
      assert_equal as_json.last['title'], "Provide a default Content Security Policy "\
        "(CSP) that is lenient yet secure"
    end
  end

  test "#as_json can get second page of issues" do
    fetcher = fetcher(repos(:rails_rails))
    fetcher.page = 2

    VCR.use_cassette "rails_rails_fetch_issues_page_two" do
      as_json = fetcher.as_json
      assert_equal 30, as_json.size, as_json
      assert_equal "Give clients a way to refer to ActionDispatch "\
        "middleware classes without triggering an early load of ActionDispatch", as_json.first['title']
      assert_equal "default_scope breaks chained having "\
        "statements in rails4", as_json.last['title']
    end
  end

  test "correctly caches when paginating" do
    fetcher = fetcher(repos(:rails_rails))

    VCR.use_cassette "rails_rails_fetch_issues" do
      assert_equal "Missing helper file helpers//Users/xxxx/"\
        "Sites/xxxx/app/helpers/application_helper.rb_helper.rb", fetcher.as_json.first['title']
    end

    fetcher.page = 2

    VCR.use_cassette "rails_rails_fetch_issues_page_two" do
      assert_equal "Give clients a way to refer to ActionDispatch "\
        "middleware classes without triggering an early load of ActionDispatch", fetcher.as_json.first['title']
    end
  end

  test "#as_json returns {} when error" do
    GitHubBub.stub(:get, ->(_, _) { raise GitHubBub::RequestError }) do
      fetcher = fetcher(repos(:rails_rails))
      assert_equal fetcher.as_json, {}
    end
  end

  test "#last_page is true when it's the last page" do
    fetcher = fetcher(repos(:rails_rails))
    GitHubBub.stub(:get, ->(_, _) { OpenStruct.new(last_page?: true) }) do
      assert fetcher.last_page?
    end
  end

  test "#last_page is false when it's not the last page" do
    fetcher = fetcher(repos(:rails_rails))
    GitHubBub.stub(:get, ->(_, _) { OpenStruct.new(last_page?: false) }) do
      assert_not fetcher.last_page?
    end
  end

  test "#error?" do
    GitHubBub.stub(:get, ->(_, _) { raise GitHubBub::RequestError }) do
      fetcher = fetcher(repos(:rails_rails))
      assert fetcher.error?
    end
  end
end
