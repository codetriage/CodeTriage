# frozen_string_literal: true

class AddDocsLivenessToRepoSubscriptions < ActiveRecord::Migration[8.1]
  def up
    add_column :repo_subscriptions, :docs_last_click_at, :datetime

    # Backfill: mark every existing doc subscription as active so none
    # pause right after deploy. Raw SQL avoids coupling to the model.
    execute(<<~SQL)
      UPDATE repo_subscriptions
      SET docs_last_click_at = NOW()
      WHERE read = true OR write = true
    SQL
  end

  def down
    remove_column :repo_subscriptions, :docs_last_click_at
  end
end
