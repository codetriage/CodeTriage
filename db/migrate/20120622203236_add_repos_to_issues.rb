class AddReposToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :repo_id, :integer
  end
end
