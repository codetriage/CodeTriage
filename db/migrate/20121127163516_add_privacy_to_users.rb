class AddPrivacyToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :private, :boolean
  end
end
