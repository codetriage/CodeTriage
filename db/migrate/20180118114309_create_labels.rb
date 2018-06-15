class CreateLabels < ActiveRecord::Migration[5.1]
  def change
    create_table :labels do |t|
      t.string :name, null: false
      t.integer :repo_id, null: false

      t.timestamps
    end

    add_index :labels, %w[name repo_id], unique: true, using: :btree
  end
end
