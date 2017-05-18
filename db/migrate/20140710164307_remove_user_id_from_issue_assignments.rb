class RemoveUserIdFromIssueAssignments < ActiveRecord::Migration[4.2]
  def change
    remove_column :issue_assignments, :user_id
  end
end
