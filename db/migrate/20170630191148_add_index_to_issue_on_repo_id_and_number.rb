class AddIndexToIssueOnRepoIdAndNumber < ActiveRecord::Migration[5.1]
  def change
    add_index(:issues, [:repo_id, :number])
  end
end
