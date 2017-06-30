class AddForeignKeyForRepoUsers < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :repo_subscriptions, :users
    add_index(:repo_subscriptions, :user_id)
  end
end
