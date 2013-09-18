class AddSkipIssuesWithPrToUsers < ActiveRecord::Migration
  def change
    add_column :users, :skip_issues_with_pr, :boolean, default: false
  end
end
