class AddClickToDocAssignments < ActiveRecord::Migration[5.0]
  def change
    add_column :doc_assignments, :clicked, :boolean, default: false
  end
end
