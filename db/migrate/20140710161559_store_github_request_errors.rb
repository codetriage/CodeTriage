class StoreGithubRequestErrors < ActiveRecord::Migration[4.2]
  def change
    add_column :repos, :github_error_msg, :text
  end
end
