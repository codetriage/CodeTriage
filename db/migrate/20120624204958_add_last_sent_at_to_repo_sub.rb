class AddLastSentAtToRepoSub < ActiveRecord::Migration
  def change
    add_column :repo_subscriptions, :last_sent_at, :datetime
  end
end
