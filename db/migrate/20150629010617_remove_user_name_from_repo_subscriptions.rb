class RemoveUserNameFromRepoSubscriptions < ActiveRecord::Migration[4.2]
  def change
    remove_column :repo_subscriptions, :user_name
  end
end
