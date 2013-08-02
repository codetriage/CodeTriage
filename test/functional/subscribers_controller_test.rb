require 'test_helper'

class SubscribersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :users, :repos

  test 'list subscribers for a repo' do
    repo = repos(:issue_triage_sandbox)
    repo.users << users(:mockstar)
    get :show, full_name: "#{repo.user_name}/#{repo.name}"
    assert_response :success
    assert_not_nil assigns(:subscribers)
    assert_not_nil assigns(:repo)
  end
end
