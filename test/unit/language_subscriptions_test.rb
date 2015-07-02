require 'test_helper'

class LanguageSubscriptionsTest < ActiveSupport::TestCase
  fixtures :users, :language_subscriptions, :repos, :issues

  test "the assign_issue for new user" do
    user          = users(:schneems)
    lang_sub      = language_subscriptions(:schneems_to_ruby)

    Issue.any_instance.stubs(:valid_for_user?).returns(true)
    lang_sub.assign_issue
    assert_equal 1, user.language_subscriptions.first.issue_assignments.count
  end

  test "the get_issue for user with existing issue assignments" do
    user          = users(:schneems)
    lang_sub      = language_subscriptions(:schneems_to_ruby)
    issue         = issues(:issue_one)
    lang_sub.issue_assignments.create! issue: issues(:issue_one)

    Issue.any_instance.stubs(:valid_for_user?).returns(true)
    lang_sub.assign_issue
    assert_equal 2, user.language_subscriptions.first.issue_assignments.count
  end

  test "email_limit allows multiple issues per repo" do
    user          = users(:schneems)
    lang_sub      = language_subscriptions(:schneems_to_ruby)

    Issue.any_instance.stubs(:valid_for_user?).returns(true)
    lang_sub.get_issues
    assert_equal 2, user.language_subscriptions.first.issue_assignments.count
  end

end
