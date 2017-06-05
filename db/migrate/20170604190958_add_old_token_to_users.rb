class AddOldTokenToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :old_token, :string
  end
end
