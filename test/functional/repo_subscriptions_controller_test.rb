# frozen_string_literal: true

require "test_helper"

class RepoSubscriptionsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "successfully subscribe to a repo when signed in as mockstar" do
    sign_in users(:mockstar)
    repo = repos(:issue_triage_sandbox)
    post :create, params: {repo_subscription: {repo_id: repo.id}}
    assert flash[:notice] == I18n.t("repo_subscriptions.subscribed")
    assert_redirected_to repo_path(repo)
  end

  test "receive failure message when subscription did not created when signed in as mockstar" do
    repo = repos(:rails_rails)
    sign_in users(:mockstar)
    RepoSubscription.any_instance.stubs(:save).returns false
    post :create, params: {repo_subscription: {repo_id: repo.id}}
    assert_equal flash[:error], "Something went wrong"
    assert_redirected_to repo_path(repo)
  end

  test "not update schneems' subscription when signed in as mockstar" do
    sign_in users(:mockstar)
    assert_raise ActiveRecord::RecordNotFound do
      patch :update, params: {id: repo_subscriptions(:schneems_to_triage).id,
                              repo_subscription: {email_limit: 12}}
    end
  end

  test "not destroy schneems' subscription when signed in as mockstar" do
    sign_in users(:mockstar)
    assert_raise ActiveRecord::RecordNotFound do
      delete :destroy, params: {id: repo_subscriptions(:schneems_to_triage).id}
    end
  end

  test "destroy a subscription" do
    before_count = RepoSubscription.count
    repo_subscription = repo_subscriptions(:schneems_to_triage)
    sign_in users(:schneems)
    delete :destroy, params: {id: repo_subscription.id}

    assert_redirected_to repo_path(repo_subscription.repo)
    assert_equal before_count - 1, RepoSubscription.count
  end

  test "update subscription limit when email limit is valid" do
    repo_subscription = repo_subscriptions(:schneems_to_triage)
    sign_in users(:schneems)
    patch :update, params: {id: repo_subscription.id,
                            repo_subscription: {email_limit: 12}}
    assert_equal flash[:success], "Preferences updated!"
    assert_redirected_to repo_path(repo_subscription.repo)
  end

  test "not update subscription when email limit is invalid" do
    repo_subscription = repo_subscriptions(:schneems_to_triage)
    sign_in users(:schneems)
    patch :update, params: {id: repo_subscription.id,
                            repo_subscription: {email_limit: -1}}
    assert_equal flash[:error], "Something went wrong"
    assert_redirected_to repo_path(repo_subscription.repo)
  end

  test "resume reactivates a doc subscription from a valid signed id" do
    sub = repo_subscriptions(:write_doc_only)
    sub.update_columns(docs_last_click_at: 90.days.ago, docs_reopt_in_sent_at: 30.days.ago)

    get :resume, params: {signed_id: sub.signed_id(purpose: :resume_docs)}

    sub.reload
    assert sub.docs_last_click_at > 1.minute.ago
    assert_nil sub.docs_reopt_in_sent_at
    assert_redirected_to repo_path(sub.repo)
  end

  test "resume with an invalid signed id redirects to root with an error" do
    get :resume, params: {signed_id: "not-a-valid-signed-id"}

    assert_equal "That re-enable link is invalid or has expired.", flash[:error]
    assert_redirected_to :root
  end
end
