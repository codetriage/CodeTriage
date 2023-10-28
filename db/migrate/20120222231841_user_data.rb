class UserData < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :zip, :string
    add_column :users, :phone_number, :string
    add_column :users, :twitter, :boolean
  end

  def down
    remove_column :users, :phone_number
  end
end
