class StoreGithubRequestErrors < ActiveRecord::Migration
  def change
    add_column :repos, :github_error_msg, :text
  end
end
