class AddIndexToIssuesCount < ActiveRecord::Migration[5.1]
  def change
    add_index :repos, :issues_count
  end
end
