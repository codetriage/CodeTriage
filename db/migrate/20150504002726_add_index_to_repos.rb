class AddIndexToRepos < ActiveRecord::Migration
  def change
    add_index :repos, :name
    add_index :repos, :user_name
  end
end
