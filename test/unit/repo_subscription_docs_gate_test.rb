# frozen_string_literal: true

require "test_helper"

class RepoSubscriptionDocsGateTest < ActiveSupport::TestCase
  # All fixture users are dated 2012, so we age one down to exercise the block.
  def new_account
    users(:mockstar).tap { |u| u.update_column(:created_at, Time.current) }
  end

  test "blocks a fresh account from enabling docs when no active doc subs exist" do
    sub = new_account.repo_subscriptions.new(repo: repos(:no_subscribers), write_limit: 1)

    refute sub.valid?
    assert_includes sub.errors[:base].join, "your account is 7 days old"
  end

  test "allows an account older than 7 days to enable docs" do
    sub = users(:schneems).repo_subscriptions.new(repo: repos(:no_subscribers), write_limit: 1)
    assert sub.valid?
  end

  test "allows a fresh account when the repo already has an active doc subscriber" do
    repo = repos(:no_subscribers)
    other = RepoSubscription.create!(repo: repo, user: users(:schneems), write_limit: 1)
    other.update_column(:docs_last_click_at, Time.current)

    sub = new_account.repo_subscriptions.new(repo: repo, read_limit: 1)
    assert sub.valid?
  end

  test "does not re-gate an existing doc subscription that only changes its limits" do
    repo = repos(:no_subscribers)
    sub = users(:mockstar).repo_subscriptions.create!(repo: repo, write_limit: 1) # allowed while old
    users(:mockstar).update_column(:created_at, Time.current) # now pretend brand-new

    sub.reload
    sub.assign_attributes(write_limit: 5)
    assert sub.valid?
  end

  test "does not gate disabling docs" do
    repo = repos(:no_subscribers)
    sub = users(:mockstar).repo_subscriptions.create!(repo: repo, write_limit: 1)
    users(:mockstar).update_column(:created_at, Time.current)

    sub.reload
    sub.assign_attributes(write_limit: 0)
    assert sub.valid?
  end

  test "seeds docs_last_click_at when a subscription becomes a doc subscription" do
    sub = users(:schneems).repo_subscriptions.create!(repo: repos(:no_subscribers), write_limit: 1)

    assert_not_nil sub.docs_last_click_at
    assert sub.docs_last_click_at > 1.minute.ago
  end

  test "does not seed docs_last_click_at for an issue-only subscription" do
    sub = users(:schneems).repo_subscriptions.create!(repo: repos(:no_subscribers), email_limit: 3)
    assert_nil sub.docs_last_click_at
  end
end
