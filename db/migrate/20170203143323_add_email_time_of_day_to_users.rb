class AddEmailTimeOfDayToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :email_time_of_day, :time
  end
end
