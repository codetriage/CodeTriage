# frozen_string_literal: true

require 'test_helper'

class ReposControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ActiveJob::TestHelper

  test 'responds with 404 if repo does not exist' do
    assert_raise(ActiveRecord::RecordNotFound) {
      get :show, params: { full_name: 'foo/bar' }
    }
  end

  test 'trying to create repo without logged in will redirect to login page' do
    assert_no_difference -> { Repo.count } do
      post :create, params: { repo: { name: 'codetriage', user_name: 'codetriage' } }
    end

    assert_redirected_to user_github_omniauth_authorize_path(origin: "/repos")
  end

  test 'do not send email for repo without issues' do
    sign_in users(:mockstar)

    assert_enqueued_jobs 2, only: SendSingleTriageEmailJob do
      VCR.use_cassette "create_repo_refinery", record: :once do
        post :create, params: { repo: { name: 'refinerycms', user_name: 'refinery' } }
      end
      VCR.use_cassette "create_repo_without_issues", record: :once do
        post :create, params: { repo: { name: 'scene-hub-v2', user_name: 'chrisccerami' } }
      end
    end
  end

  test 'logged in user can create repo' do
    sign_in users(:mockstar)

    VCR.use_cassette "create_repo_refinery", record: :once do
      assert_difference -> { Repo.count } do
        post :create, params: { repo: { name: 'refinerycms', user_name: 'refinery' } }
      end
    end

    assert_redirected_to repo_path('refinery/refinerycms')
  end
end
