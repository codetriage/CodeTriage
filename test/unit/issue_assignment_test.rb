# frozen_string_literal: true

require 'test_helper'

class IssueAssignmentTest < ActiveSupport::TestCase
  test "validates presence of relevant ids" do
    ia = IssueAssignment.new
    ia.valid?
    assert_equal ["can't be blank"], ia.errors[:issue_id]
  end

  test "issue assigner class works" do
    user = users(:schneems)

    # schneems has 2 repo subscriptions, only the first one has

    user.issue_assignments.where(delivered: false).delete_all

    assigner = IssueAssigner.new(user, user.repo_subscriptions)
    assigner.assign!

    assert_equal 3, user.issue_assignments.where(delivered: false).count
  end

  test "respects email limits" do
    user = users(:schneems)

    user.issue_assignments.where(delivered: false).delete_all

    user.repo_subscriptions.each do |sub|
      3.times do
        sub.repo.issues.create!(state: Issue::OPEN, number: rand(22...2222))
      end
    end

    subscriptions = user.repo_subscriptions.all
    first_sub = subscriptions.first
    second_sub = subscriptions.last
    def first_sub.email_limit; 1; end

    def second_sub.email_limit; 1; end

    assigner = IssueAssigner.new(user, [first_sub, second_sub])
    assigner.assign!

    assert_equal 2, user.issue_assignments.where(delivered: false).count
  end

  test "can check github API" do
    user = users(:schneems)

    user.issue_assignments.where(delivered: false).delete_all

    assert_equal 0, user.issue_assignments.where(delivered: false).count

    repo = Repo.where(full_name: "bemurphy/issue_triage_sandbox").first
    sub = user.repo_subscriptions.where(repo_id: repo.id).first
    def sub.email_limit; 1; end

    repo.issues.each do |issue|
      stub_request(:get, %r{https://api.github.com/repos/bemurphy/issue_triage_sandbox/issues/#{issue.number}})
       .to_return({ body: issue.as_json.to_json, status: 200})

      stub_request(:get, %r{https://api.github.com/repos/bemurphy/issue_triage_sandbox/issues/#{issue.number}/comments})
        .to_return({
          body: [{ "id" => 5, "user" => { "login" => "rtomayko", "id" => 404 } }].to_json,
          status: 200
        })
    end

    assigner = IssueAssigner.new(user, [sub], can_access_network: true)
    assigner.assign!
    assert_equal 1, user.issue_assignments.where(delivered: false).count
  end
end
