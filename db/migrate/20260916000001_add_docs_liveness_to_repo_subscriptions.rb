# frozen_string_literal: true

class AddDocsLivenessToRepoSubscriptions < ActiveRecord::Migration[8.1]
  def up
    add_column :repo_subscriptions, :docs_last_click_at, :datetime
    add_column :repo_subscriptions, :docs_reopt_in_sent_at, :datetime

    # Backfill: seed every existing doc subscription as active so the redefined
    # docs_subscriber_count equals the old count immediately after deploy and
    # nothing pauses on day one. Raw SQL avoids coupling to the model.
    execute(<<~SQL)
      UPDATE repo_subscriptions
      SET docs_last_click_at = NOW()
      WHERE read = true OR write = true
    SQL
  end

  def down
    remove_column :repo_subscriptions, :docs_reopt_in_sent_at
    remove_column :repo_subscriptions, :docs_last_click_at
  end
end
