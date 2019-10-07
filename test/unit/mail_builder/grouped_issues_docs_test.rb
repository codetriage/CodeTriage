# frozen_string_literal: true

require 'test_helper'

class GroupedIssuesDocsTest < ActiveSupport::TestCase
  test "two issues different repos in random order" do
    assignment_one    = issue_assignments(:schneems_triage_issue_assignment)
    expected_repo_one = assignment_one.repo
    user              = assignment_one.repo_subscription.user

    assignment_two    = issue_assignments(:schneems_sinatra_issue_assignment)
    expected_repo_two = assignment_two.repo

    assert_not_equal expected_repo_one, expected_repo_two

    assignment_ids = [assignment_one.id, assignment_two.id]

    order_one_repos = [assignment_one.repo, assignment_two.repo]
    order_two_repos = order_one_repos.reverse

    actual = MailBuilder::GroupedIssuesDocs.new(
      user_id: user.id,
      assignment_ids: assignment_ids,
      random_seed: 1
    ).map(&:repo)

    assert_equal true, actual.include?(expected_repo_one), "Expected #{actual} to include #{expected_repo_one} but it did not"
    assert_equal true, actual.include?(expected_repo_two), "Expected #{actual} to include #{expected_repo_two} but it did not"

    assert_equal order_one_repos, actual

    actual = MailBuilder::GroupedIssuesDocs.new(
      user_id: user.id,
      assignment_ids: assignment_ids,
      random_seed: 2
    ).map(&:repo)

    assert_equal order_two_repos, actual
  end

  test "empty group works" do
    user = users(:schneems)

    group = MailBuilder::GroupedIssuesDocs.new(user_id: user.id)
    assert_equal false, group.any_docs?
    assert_equal false, group.any_issues?
    assert_equal 0,     group.count
    group.each { raise "there should be nothing to iterate" }
  end

  test "only an assignment" do
    assignment    = issue_assignments(:one)
    expected_repo = assignment.repo
    user          = assignment.repo_subscription.user

    group = MailBuilder::GroupedIssuesDocs.new(
      user_id: user.id,
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
      user_id: user.id,
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
    subscription = repo_subscriptions(:write_doc_only)
    # write_doc_only

    expected_repo = subscription.repo
    user          = subscription.user
    doc           = doc_methods(:issue_triage_doc)
    assert_equal expected_repo, repos(:issue_triage_sandbox)

    group = MailBuilder::GroupedIssuesDocs.new(
      user_id: user.id,
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
      user_id: user.id,
      assignment_ids: [assignment.id],
      write_doc_ids: [doc.id]
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
