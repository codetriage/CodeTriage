class ReposNameIndex < ActiveRecord::Migration[5.0]
  def change
    add_index :repos, :user_name
    add_index :repos, :name
  end
end
