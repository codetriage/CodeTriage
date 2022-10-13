# frozen_string_literal: true

require 'test_helper'
class UpdateRepoInfoJobTest < ActiveJob::TestCase
  test 'repo deleted or made private' do
    GithubFetcher::Resource.any_instance.stubs(:status).returns(404)
    repo = repos(:node)
    assert_changes -> {
      [
        repo.removed_from_github,
      ]
    } do
      UpdateRepoInfoJob.perform_now(repo)
      repo.reload
    end
    assert repo.removed_from_github
  end

  test 'repo with information updated' do
    GithubFetcher::Resource.any_instance.stubs(:status).returns(200)
    GithubFetcher::Resource.any_instance.stubs(:as_json).returns(
      {
        'full_name' => 'test_owner/test_repo',
        'language' => 'test_language',
        'description' => 'test_description',
        'archived' => true
      }
    )
    repo = repos(:node)
    assert_changes -> {
      [
        repo.full_name,
        repo.name,
        repo.user_name,
        repo.language,
        repo.description,
        repo.archived
      ]
    } do
      UpdateRepoInfoJob.perform_now(repo)
      repo.reload
    end
    assert_equal false, repo.removed_from_github
    assert_equal 'test_owner/test_repo', repo.full_name
    assert_equal 'test_repo', repo.name
    assert_equal 'test_owner', repo.user_name
    assert_equal 'test_language', repo.language
    assert_equal 'test_description', repo.description
    assert_equal true, repo.archived
  end

  test 'repo rename conflict' do
    GithubFetcher::Resource.any_instance.stubs(:status).returns(200)
    GithubFetcher::Resource.any_instance.stubs(:as_json).returns(
      {
        'full_name' => 'sinatra/sinatra',
      }
    )
    repo = repos(:node)
    assert_no_changes -> {
      [
        repo.full_name,
        repo.name,
        repo.user_name,
        repo.language,
        repo.description,
        repo.archived
      ]
    } do
      UpdateRepoInfoJob.perform_now(repo)
      repo.reload
    end
  end
end
