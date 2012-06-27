class AddRepoSubToIssueAssignment < ActiveRecord::Migration
  def change
    add_column :issue_assignments, :repo_subscription_id, :integer
  end
end
