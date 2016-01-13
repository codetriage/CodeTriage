require 'test_helper'

class RepoSubscriptionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :users, :repos, :repo_subscriptions

  setup do
    request.env["HTTP_REFERER"] = "http://localhost:5000"
  end

  test 'successfully subscribe to a repo when signed in as mockstar' do
    sign_in users(:mockstar)
    repo = repos(:issue_triage_sandbox)
    post :create, params: { repo_id: repo.id }
    assert flash[:notice] == I18n.t('repo_subscriptions.subscribed')
    assert_redirected_to repo_path(repo)
  end

  test 'receive failure message when subscription did not created when signed in as mockstar' do
    sign_in users(:mockstar)
    RepoSubscription.any_instance.stubs(:save).returns false
    post :create, params: { repo_id: repos(:rails_rails).id }
    assert_equal flash[:error], "Something went wrong"
    assert_redirected_to :back
  end

  test "not update schneems' subscription when signed in as mockstar" do
    sign_in users(:mockstar)
    assert_raise ActiveRecord::RecordNotFound do
      patch :update, params: { id: repo_subscriptions(:schneems_to_triage).id,
                               repo_subscription: { email_limit: 12 } }
    end
  end

  test "not destroy schneems' subscription when signed in as mockstar" do
    sign_in users(:mockstar)
    assert_raise ActiveRecord::RecordNotFound do
      delete :destroy, params: { id: repo_subscriptions(:schneems_to_triage).id }
    end
  end

  test 'destroy a subscription' do
    sign_in users(:schneems)
    delete :destroy, params: { id: repo_subscriptions(:schneems_to_triage).id }
    assert_redirected_to :back
    assert_equal 1, RepoSubscription.count
  end

  test 'update subscription limit when email limit is valid' do
    sign_in users(:schneems)
    patch :update, params: { id: repo_subscriptions(:schneems_to_triage).id,
                             repo_subscription: { email_limit: 12 } }
    assert_equal flash[:success], "Email preferences updated!"
    assert_redirected_to :back
  end

  test 'not update subscription when email limit is invalid' do
    sign_in users(:schneems)
    patch :update, params: { id: repo_subscriptions(:schneems_to_triage).id,
                             repo_subscription: { email_limit: 0 } }
    assert_equal flash[:error], "Something went wrong"
    assert_redirected_to :back
  end
end
