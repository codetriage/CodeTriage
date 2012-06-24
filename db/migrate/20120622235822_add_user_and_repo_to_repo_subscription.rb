class AddUserAndRepoToRepoSubscription < ActiveRecord::Migration
  def change
    add_column :repo_subscriptions, :user_id, :integer
    add_column :repo_subscriptions, :repo_id, :integer
  end
end
