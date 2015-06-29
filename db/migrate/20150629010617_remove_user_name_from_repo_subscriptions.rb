class RemoveUserNameFromRepoSubscriptions < ActiveRecord::Migration
  def change
    remove_column :repo_subscriptions, :user_name
  end
end
