class RemoveUserIdFromIssueAssignments < ActiveRecord::Migration
  def change
    remove_column :issue_assignments, :user_id
  end
end
