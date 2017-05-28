class RemoveRepoNameFromRepoSubscriptions < ActiveRecord::Migration[4.2]
  def change
    remove_column :repo_subscriptions, :repo_name
  end
end
