class AddRepoSubToIssueAssignment < ActiveRecord::Migration[4.2]
  def change
    add_column :issue_assignments, :repo_subscription_id, :integer
  end
end
