class FixDocMethodsIndexes < ActiveRecord::Migration[5.1]
  def change
    remove_index(:doc_methods, name: "index_doc_methods_on_repo_id_and_created_at")
    add_index(:doc_methods, [:repo_id, :id])
  end
end
