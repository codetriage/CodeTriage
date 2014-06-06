class AddDeleteTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_delete_token, :string
    add_index  :users, :account_delete_token
  end
end
