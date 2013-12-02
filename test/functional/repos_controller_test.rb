require 'test_helper'

class ReposControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :users, :repos

  test 'responds with 404 if repo does not exist' do
    assert_raise(ActiveRecord::RecordNotFound) {
      get :show, full_name: 'foo/bar'
    }
  end

  test 'finds own, starred and watched repos on #new' do
    fake_repo_response         = stub(json_body: {})
    fake_starred_repo_response = stub(json_body: {})
    fake_subscription_response = stub(json_body: {})

    GitHubBub.expects(:get).with('/user/repos', token: nil, type: 'owner', per_page: '100').returns(fake_repo_response)
    GitHubBub.expects(:get).with('/user/starred', token: nil).returns(fake_starred_repo_response)
    GitHubBub.expects(:get).with('/user/subscriptions', token: nil).returns(fake_subscription_response)

    sign_in users(:mockstar)
    get :new

    assert_response 200
  end
end
