class AddLabelsForIssues < ActiveRecord::Migration[5.0]
  def change
    create_table :issue_labels, id: false, force: :cascade do |t|
      t.integer :repo_id, null: false
      t.integer :issue_id, null: false
      t.text    :name, null: false
    end

    add_column :issues, :label_count, :integer

    add_index :issue_labels, %w[issue_id], unique: true, using: :btree
    add_index :issue_labels, %w[repo_id name issue_id], unique: true, using: :btree
  end
end
