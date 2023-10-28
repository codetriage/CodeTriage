class AddDeleteTokenToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :account_delete_token, :string
    add_index :users, :account_delete_token
  end
end
