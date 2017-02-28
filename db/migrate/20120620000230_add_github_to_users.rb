class AddGithubToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :github, :string
    add_column :users, :github_access_token, :string
    add_index  :users, :github, unique: true
  end
end
