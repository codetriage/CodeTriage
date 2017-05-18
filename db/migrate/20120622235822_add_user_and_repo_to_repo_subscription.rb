class AddUserAndRepoToRepoSubscription < ActiveRecord::Migration[4.2]
  def change
    add_column :repo_subscriptions, :user_id, :integer
    add_column :repo_subscriptions, :repo_id, :integer
  end
end
