class CreateRepoLabelsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :repo_labels do |t|
      t.references :repo, foreign_key: true, null: false
      t.references :label, foreign_key: true, null: false

      t.timestamps
    end

    add_index :repo_labels, [:repo_id, :label_id], unique: true
  end
end
