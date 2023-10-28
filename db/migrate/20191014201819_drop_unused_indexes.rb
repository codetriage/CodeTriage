class DropUnusedIndexes < ActiveRecord::Migration[6.0]
  def change
    # public.issues            | index_issues_on_number                                         | 198 MB     |           0
    # public.issues            | index_issues_on_repo_id                                        | 1536 MB    |           0
    # public.issue_assignments | index_issue_assignments_on_repo_subscription_id_and_created_at | 370 MB     |           0
    remove_index(:issues, name: "index_issues_on_number")
    remove_index(:issues, name: "index_issues_on_repo_id")
    remove_index(:issue_assignments, name: "index_issue_assignments_on_repo_subscription_id_and_created_at")
  end
end
