class AddDocsSubscriberCountToRepos < ActiveRecord::Migration[6.0]
  def change
    add_column :repos, :docs_subscriber_count, :integer, default: 0
  end
end
