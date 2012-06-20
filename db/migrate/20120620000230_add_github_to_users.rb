class AddGithubToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github, :string
    add_index  :users, :github, :unique => true
  end
end
