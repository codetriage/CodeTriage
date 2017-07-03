class AddIndexToDocMethod < ActiveRecord::Migration[5.1]
  def change
    add_index(:doc_methods, [:repo_id, :created_at])
  end
end
