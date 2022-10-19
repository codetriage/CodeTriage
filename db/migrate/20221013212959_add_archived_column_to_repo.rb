class AddArchivedColumnToRepo < ActiveRecord::Migration[7.0]
  def change
    add_column :repos, :archived, :boolean, default: false
    add_index :repos, :archived
  end
end
