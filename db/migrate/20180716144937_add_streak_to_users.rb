class AddStreakToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :raw_streak_count, :integer, default: 0
    add_column :users, :raw_emails_since_click, :integer, default: 0
  end
end
