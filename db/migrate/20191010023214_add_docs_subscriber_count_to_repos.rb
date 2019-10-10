class AddDocsSubscriberCountToRepos < ActiveRecord::Migration[6.0]
  def change
    add_column :repos, :docs_subscriber_count, :integer, default: 0
    add_index :repo_subscriptions, :read
    add_index :repo_subscriptions, :write
    add_index :repo_subscriptions, :repo_id
  end
end
