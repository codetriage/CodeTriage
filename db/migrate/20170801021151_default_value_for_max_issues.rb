class DefaultValueForMaxIssues < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :daily_issue_limit, 50
  end
end
