class AddLastSentAtToRepoSub < ActiveRecord::Migration[4.2]
  def change
    add_column :repo_subscriptions, :last_sent_at, :datetime
  end
end
