class AddUniqueIndexesToDocMethods < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    remove_index :doc_methods, [:repo_id, :name, :path]
    add_index :doc_methods, [:repo_id, :name, :path], unique: true, algorithm: :concurrently
  end
end
