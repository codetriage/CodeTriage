class RemoveRepoNameFromRepoSubscription < ActiveRecord::Migration
  def change
    remove_column :repo_subscriptions, :repo_name
  end
end
