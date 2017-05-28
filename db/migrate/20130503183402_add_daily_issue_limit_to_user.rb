class AddDailyIssueLimitToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :daily_issue_limit, :integer
  end
end
