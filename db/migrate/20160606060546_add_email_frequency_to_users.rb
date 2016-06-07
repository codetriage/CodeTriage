class AddEmailFrequencyToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :email_frequency, :string, default: "daily"
  end
end
