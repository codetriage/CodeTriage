class AddIndexToIssues < ActiveRecord::Migration[4.2]
  def change
    add_index :issues, :state
    add_index :issues, :number
    add_index :issues, :repo_id
  end
end
