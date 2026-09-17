# frozen_string_literal: true

require "test_helper"

class DocMethodsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    sign_in users(:schneems)
    @user = users(:schneems)
    @triage_doc = doc_methods(:issue_triage_doc)
    @repo_sub = RepoSubscription.where(user_id: @user.id, repo: @triage_doc.repo).first
  end

  test "click_method_redirect with a DocAssignment redirects to the doc_method url" do
    DocAssignment.create(doc_method_id: @triage_doc.id, repo_subscription_id: @repo_sub.id)

    get :click_method_redirect, params: {id: @triage_doc.id, user_id: @user.id}

    assert_redirected_to doc_method_url(@triage_doc)
  end

  test "click_method_redirect without any DocAssignment returns to root an displays an error" do
    get :click_method_redirect, params: {id: @triage_doc.id, user_id: @user.id}

    assert flash[:notice].eql? "Bad url, if this problem persists please open an issue github.com/codetriage/codetriage"
    assert_redirected_to :root
  end

  test "click_method_redirect stamps docs_last_click_at and clears reopt-in" do
    DocAssignment.create(doc_method_id: @triage_doc.id, repo_subscription_id: @repo_sub.id)
    @repo_sub.update_columns(docs_last_click_at: 90.days.ago, docs_reopt_in_sent_at: 30.days.ago)

    get :click_method_redirect, params: {id: @triage_doc.id, user_id: @user.id}

    @repo_sub.reload
    assert @repo_sub.docs_last_click_at > 1.minute.ago
    assert_nil @repo_sub.docs_reopt_in_sent_at
  end

  test "click_source_redirect stamps docs_last_click_at and clears reopt-in" do
    DocAssignment.create(doc_method_id: @triage_doc.id, repo_subscription_id: @repo_sub.id)
    @repo_sub.update_columns(docs_last_click_at: 90.days.ago, docs_reopt_in_sent_at: 30.days.ago)

    get :click_source_redirect, params: {id: @triage_doc.id, user_id: @user.id}

    @repo_sub.reload
    assert @repo_sub.docs_last_click_at > 1.minute.ago
    assert_nil @repo_sub.docs_reopt_in_sent_at
  end
end
