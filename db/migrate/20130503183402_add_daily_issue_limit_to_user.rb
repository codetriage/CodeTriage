class AddDailyIssueLimitToUser < ActiveRecord::Migration
  def change
    add_column :users, :daily_issue_limit, :integer
  end
end
