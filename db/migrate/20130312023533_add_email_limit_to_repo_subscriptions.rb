class AddEmailLimitToRepoSubscriptions < ActiveRecord::Migration
  def change
    add_column :repo_subscriptions, :email_limit, :integer, default: 1
  end
end

