require 'test_helper'

class GroupedIssuesDocsTest < ActiveSupport::TestCase
  test "empty group works" do
    user = users(:schneems)

    group = MailBuilder::GroupedIssuesDocs.new(user_id: user.id)
    assert_equal false, group.any_docs?
    assert_equal false, group.any_issues?
    assert_equal 0,     group.count
    group.each {|g| raise "there should be nothing to iterate" }
  end

  test "only an assignment" do
    assignment    = issue_assignments(:one)
    expected_repo = assignment.repo
    user          = assignment.repo_subscription.user

    group = MailBuilder::GroupedIssuesDocs.new(
      user_id:        user.id,
      assignment_ids: [assignment.id]
    )
    assert_equal false, group.any_docs?
    assert_equal true, group.any_issues?
    assert_equal 1,    group.count

    group.each do |g|
      assert_equal true, g.repo        == expected_repo
      assert_equal true, g.assignments == [assignment]
      assert_equal true, g.read_docs   == []
      assert_equal true, g.write_docs  == []
    end
  end

  test "only a read doc" do
    subscription  = repo_subscriptions(:read_doc_only)
    expected_repo = subscription.repo
    user          = subscription.user
    doc           = doc_methods(:issue_triage_doc)
    assert_equal expected_repo, repos(:issue_triage_sandbox)

    group = MailBuilder::GroupedIssuesDocs.new(
      user_id:      user.id,
      read_doc_ids: [doc.id]
    )
    assert_equal true,  group.any_docs?
    assert_equal false, group.any_issues?
    assert_equal 1,     group.count

    group.each do |g|
      assert_equal true, g.repo        == expected_repo
      assert_equal true, g.assignments == []
      assert_equal true, g.read_docs   == [doc]
      assert_equal true, g.write_docs  == []
    end
  end

  test "only a write doc" do
    subscription  = repo_subscriptions(:write_doc_only)
    # write_doc_only

    expected_repo = subscription.repo
    user          = subscription.user
    doc           = doc_methods(:issue_triage_doc)
    assert_equal expected_repo, repos(:issue_triage_sandbox)

    group = MailBuilder::GroupedIssuesDocs.new(
      user_id:       user.id,
      write_doc_ids: [doc.id]
    )
    assert_equal true,  group.any_docs?
    assert_equal false, group.any_issues?
    assert_equal 1,     group.count

    group.each do |g|
      assert_equal expected_repo, g.repo
      assert_equal [],            g.assignments
      assert_equal [],            g.read_docs
      assert_equal [doc],         g.write_docs
    end
  end

  test "issue and a doc for same repo" do
    subscription  = repo_subscriptions(:schneems_to_triage)
    assignment    = issue_assignments(:one)

    assert_equal assignment.repo_subscription, subscription
    # write_doc_only

    expected_repo = subscription.repo
    user          = subscription.user
    doc           = doc_methods(:issue_triage_doc)
    assert_equal expected_repo, repos(:issue_triage_sandbox)

    group = MailBuilder::GroupedIssuesDocs.new(
      user_id:        user.id,
      assignment_ids: [assignment.id],
      write_doc_ids:  [doc.id]
    )
    assert_equal true, group.any_docs?
    assert_equal true, group.any_issues?
    assert_equal 1,    group.count

    group.each do |g|
      assert_equal expected_repo, g.repo
      assert_equal [assignment],  g.assignments
      assert_equal [],            g.read_docs
      assert_equal [doc],         g.write_docs
    end
  end
end
