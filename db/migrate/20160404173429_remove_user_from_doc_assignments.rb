class RemoveUserFromDocAssignments < ActiveRecord::Migration[5.0]
  def change
    remove_column :doc_assignments, :user_id
  end
end
