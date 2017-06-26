class MakeMultiIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index(:issues, :created_at) if index_exists?(:issues, :created_at)
    add_index(:issues, [:repo_id, :created_at], where: "state = '#{Issue::OPEN}'")
  end
end
