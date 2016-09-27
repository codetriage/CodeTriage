class AddIndexToRepoSubscriptionId < ActiveRecord::Migration[5.0]
  def change
    add_index :issue_assignments, :repo_subscription_id
  end
end
