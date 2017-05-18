class AddReposToIssues < ActiveRecord::Migration[4.2]
  def change
    add_column :issues, :repo_id, :integer
  end
end
