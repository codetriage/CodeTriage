class AddIndexToDocMethodCreation < ActiveRecord::Migration[5.1]
  def change
    add_index(:doc_methods, [:repo_id, :name, :path])
  end
end
