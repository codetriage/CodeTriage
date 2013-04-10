require 'test_helper'

class RepoSubscriptionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :users, :repos

  setup do
    sign_in users(:mockstar)
  end

  test 'successfully subscribe to a repo' do
    post :create, repo_id: repos(:rails_rails).id
    assert flash[:notice] == I18n.t('repo_subscriptions.subscribed')
    assert_redirected_to repo_subscriptions_path
  end
end

