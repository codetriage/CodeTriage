class CreateIssueAssignments < ActiveRecord::Migration[4.2]
  def change
    create_table :issue_assignments do |t|
      t.integer :user_id
      t.integer :issue_id

      t.timestamps
    end
  end
end
