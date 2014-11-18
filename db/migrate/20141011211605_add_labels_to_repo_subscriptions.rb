class AddLabelsToRepoSubscriptions < ActiveRecord::Migration
  def change
    add_column :repo_subscriptions, :labels, :string, array: true
  end
end
