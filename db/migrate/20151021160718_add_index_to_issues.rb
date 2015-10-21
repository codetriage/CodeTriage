class AddIndexToIssues < ActiveRecord::Migration
  def change
    add_index :issues, :state
    add_index :issues, :number
    add_index :issues, :repo_id
  end
end
