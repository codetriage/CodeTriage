class CreateRepoSubscriptions < ActiveRecord::Migration
  def change
    create_table :repo_subscriptions do |t|
      t.string      :user_name
      t.string      :repo_name
      t.timestamps
    end
  end
end
