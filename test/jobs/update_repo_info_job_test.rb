# frozen_string_literal: true

require 'test_helper'

# frozen_string_literal: true

require 'test_helper'
class UpdateRepoInfoJobTest < ActiveJob::TestCase
  test 'repo deleted or made private' do
    GithubFetcher::Resource.any_instance.stubs(:status).returns(404)
    @repo = repos(:node)
    assert_changes -> {
      [
        @repo.reload.removed_from_github,
      ]
    } do
      UpdateRepoInfoJob.perform_now(@repo)
    end
    assert @repo.reload.removed_from_github
  end

  test 'repo with information updated' do
    GithubFetcher::Resource.any_instance.stubs(:status).returns(200)
    GithubFetcher::Resource.any_instance.stubs(:as_json).returns(
      {
        'full_name' => 'test_owner/test_repo',
        'language' => 'test_language',
        'description' => 'test_description'
      }
    )
    @repo = repos(:node)
    assert_changes -> {
      [
        @repo.reload.full_name,
        @repo.reload.name,
        @repo.reload.user_name,
        @repo.reload.language,
        @repo.reload.description,
      ]
    } do
      UpdateRepoInfoJob.perform_now(@repo)
    end
    assert_equal false, @repo.reload.removed_from_github
    assert_equal 'test_owner/test_repo', @repo.reload.full_name
    assert_equal 'test_repo', @repo.reload.name
    assert_equal 'test_owner', @repo.reload.user_name
    assert_equal 'test_language', @repo.reload.language
    assert_equal 'test_description', @repo.reload.description
  end

  test 'repo rename conflict' do
    GithubFetcher::Resource.any_instance.stubs(:status).returns(200)
    GithubFetcher::Resource.any_instance.stubs(:as_json).returns(
      {
        'full_name' => 'sinatra/sinatra',
      }
    )
    @repo = repos(:node)
    assert_no_changes -> {
      [
        @repo.reload.full_name,
        @repo.reload.name,
        @repo.reload.user_name,
        @repo.reload.language,
        @repo.reload.description,
      ]
    } do
      UpdateRepoInfoJob.perform_now(@repo)
    end
  end
end
