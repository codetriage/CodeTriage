require 'test_helper'

class ReposControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :users, :repos

  test 'responds with 404 if repo does not exist' do
    assert_raise(ActiveRecord::RecordNotFound) {
      get :show, full_name: 'foo/bar'
    }
  end

  test 'trying to create repo without logged in will redirect to login page' do
    assert_no_difference -> { Repo.count } do
      post :create, repo: { name: 'codetriage', user_name: 'codetriage' }
    end

    assert_redirected_to new_user_session_path
  end

  test 'do not send email for repo without issues' do
    sign_in users(:mockstar)
    UserMailer.any_instance.expects(:send_triage).once
    VCR.use_cassette "create_repo_refinery", record: :once do
      post :create, repo: { name: 'refinerycms', user_name: 'refinery' }
    end
    VCR.use_cassette "create_repo_without_issues", record: :once do
      post :create, repo: { name: 'scene-hub-v2', user_name: 'chrisccerami' }
    end
  end

  test 'logged in user can create repo' do
    sign_in users(:mockstar)

    VCR.use_cassette "create_repo_refinery", record: :once do
      assert_difference -> { Repo.count } do
        post :create, repo: { name: 'refinerycms', user_name: 'refinery' }
      end
    end

    assert_redirected_to repo_path('refinery/refinerycms')
  end
end
