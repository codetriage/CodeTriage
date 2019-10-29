class AddUniqueIndexNumberRepoId < ActiveRecord::Migration[6.0]
  def change
    add_index :issues, [:number, :repo_id], unique: true
  end
end
