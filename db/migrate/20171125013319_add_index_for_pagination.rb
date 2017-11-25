class AddIndexForPagination < ActiveRecord::Migration[5.1]
  def change
    add_index(:issues, [:repo_id, :id], where: "state = '#{Issue::OPEN}'")
  end
end
