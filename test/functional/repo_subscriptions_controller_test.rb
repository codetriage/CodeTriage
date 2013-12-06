require 'test_helper'

class RepoSubscriptionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :users, :repos, :repo_subscriptions

  setup do
    request.env["HTTP_REFERER"] = "http://localhost:5000"
  end

  context 'when signed in as mockstar' do
    setup do
      sign_in users(:mockstar)
    end

    should 'successfully subscribe to a repo' do
      post :create, repo_id: repos(:rails_rails).id
      assert flash[:notice] == I18n.t('repo_subscriptions.subscribed')
      assert_redirected_to repo_subscriptions_path
    end

    should 'recive failure message when subscription did not created' do
      RepoSubscription.any_instance.stubs(:save).returns false
      post :create, repo_id: repos(:rails_rails).id
      assert_equal flash[:error], "Something went wrong"
      assert_redirected_to :back
    end

    should "not update schneems' subscription" do
      assert_raise ActiveRecord::RecordNotFound do
        patch :update, id: repo_subscriptions(:schneems_to_triage).id,
          repo_subscription: { email_limit: 12 }
      end
    end

    should "not destroy schneems' subscription" do
      assert_raise ActiveRecord::RecordNotFound do
        delete :destroy, id: repo_subscriptions(:schneems_to_triage).id
      end
    end
  end

  context 'when signed in as schneems' do
    setup do
      sign_in users(:schneems)
    end

    should 'destroy a subscription' do
      delete :destroy, id: repo_subscriptions(:schneems_to_triage).id
      assert_redirected_to :back
      assert_equal 1, RepoSubscription.count
    end

    should 'update subscription limit when email limit is valid' do
      patch :update, id: repo_subscriptions(:schneems_to_triage).id,
        repo_subscription: { email_limit: 12 }
      assert_equal flash[:success], "Email preferences updated!"
      assert_redirected_to :back
    end

    should 'not update subscription when email limit is invalid' do
      patch :update, id: repo_subscriptions(:schneems_to_triage).id,
        repo_subscription: { email_limit: 0 }
      assert_equal flash[:error], "Something went wrong"
      assert_redirected_to :back
    end
  end
end

