require 'test_helper'

class SubscribersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :users, :repos

  test 'list subscribers for a repo' do
    repo = repos(:issue_triage_sandbox)
    repo.users << users(:mockstar)
    get :show, name: repo.name, user_name: repo.user_name
    assert_response :success
    assert_not_nil assigns(:subscribers)
    assert_not_nil assigns(:repo)
  end
end
