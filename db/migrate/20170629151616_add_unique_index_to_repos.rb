class AddUniqueIndexToRepos < ActiveRecord::Migration[5.1]
  def change
    add_index :repos, [:name, :user_name], unique: true
  end
end
