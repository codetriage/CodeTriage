class AddEmailLimitToRepoSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :repo_subscriptions, :email_limit, :integer, default: 1
  end
end
