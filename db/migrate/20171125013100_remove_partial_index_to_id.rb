class RemovePartialIndexToId < ActiveRecord::Migration[5.1]
  def change
    remove_index(:issues, name: "index_issues_on_repo_id_and_created_at")
    remove_index(:issues, name: "index_issues_on_id")
  end
end
