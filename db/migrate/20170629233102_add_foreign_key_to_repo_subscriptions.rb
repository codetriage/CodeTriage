class AddForeignKeyToRepoSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :repo_subscriptions, :repos
    add_index(:repo_subscriptions, :repo_id)
  end
end
