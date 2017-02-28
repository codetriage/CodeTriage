class AddSkipIssuesWithPrToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :skip_issues_with_pr, :boolean, default: false
  end
end
