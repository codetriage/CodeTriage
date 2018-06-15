class CreateIssueLabels < ActiveRecord::Migration[5.1]
  def change
    create_table :issue_labels do |t|
      t.integer :issue_id
      t.integer :label_id
    end

    add_index :issue_labels, %w[issue_id label_id]
  end
end
